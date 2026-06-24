import logging
from typing import Any

from backend.config import settings

logger = logging.getLogger(__name__)

_firebase_available = False
_in_memory_store: dict[str, dict[str, dict]] = {}


def init_storage():
    global _firebase_available
    if not settings.firebase_project_id:
        logger.info("No Firebase project configured; using in-memory storage")
        return
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore

        cred_dict = {
            "type": settings.firebase_type,
            "project_id": settings.firebase_project_id,
            "private_key_id": settings.firebase_private_key_id,
            "private_key": settings.firebase_private_key,
            "client_email": settings.firebase_client_email,
            "client_id": settings.firebase_client_id,
            "auth_uri": settings.firebase_auth_uri,
            "token_uri": settings.firebase_token_uri,
            "auth_provider_x509_cert_url": settings.firebase_auth_provider_x509_cert_url,
            "client_x509_cert_url": settings.firebase_client_x509_cert_url,
        }
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)
        _firebase_available = True
        logger.info("Firebase initialized successfully")
    except Exception as e:
        logger.warning("Firebase init failed (%s); using in-memory storage", e)


def _db():
    if not _firebase_available:
        return None
    try:
        from firebase_admin import firestore
        return firestore.client()
    except Exception:
        return None


def _try_firebase(fn, fallback):
    try:
        return fn()
    except Exception as e:
        logger.debug("Firestore call failed (%s); falling back to in-memory", e)
        return fallback()


def create_document(collection: str, doc_id: str, data: dict) -> None:
    db = _db()
    if db:
        def fb():
            db.collection(collection).document(doc_id).set(data)
        def mem():
            _in_memory_store.setdefault(collection, {})[doc_id] = data
        _try_firebase(fb, mem)
        return
    _in_memory_store.setdefault(collection, {})[doc_id] = data


def get_document(collection: str, doc_id: str) -> dict[str, Any] | None:
    db = _db()
    if db:
        def fb():
            doc = db.collection(collection).document(doc_id).get()
            return doc.to_dict() if doc.exists else None
        def mem():
            return _in_memory_store.get(collection, {}).get(doc_id)
        return _try_firebase(fb, mem)
    return _in_memory_store.get(collection, {}).get(doc_id)


def update_document(collection: str, doc_id: str, data: dict) -> None:
    db = _db()
    if db:
        def fb():
            db.collection(collection).document(doc_id).update(data)
        def mem():
            store = _in_memory_store.get(collection, {})
            if doc_id in store:
                store[doc_id].update(data)
        _try_firebase(fb, mem)
        return
    store = _in_memory_store.get(collection, {})
    if doc_id in store:
        store[doc_id].update(data)


def query_collection(collection: str, order_by: str | None = None, limit: int = 50) -> list[dict[str, Any]]:
    db = _db()
    if db:
        def fb():
            from firebase_admin import firestore
            ref = db.collection(collection)
            if order_by:
                ref = ref.order_by(order_by, direction=firestore.Query.DESCENDING)
            docs = ref.limit(limit).stream()
            return [{**d.to_dict(), "id": d.id} for d in docs]
        def mem():
            store = _in_memory_store.get(collection, {})
            docs = [{"id": k, **v} for k, v in store.items()]
            if order_by:
                docs.sort(key=lambda d: d.get(order_by, ""), reverse=True)
            return docs[:limit]
        return _try_firebase(fb, mem)
    store = _in_memory_store.get(collection, {})
    docs = [{"id": k, **v} for k, v in store.items()]
    if order_by:
        docs.sort(key=lambda d: d.get(order_by, ""), reverse=True)
    return docs[:limit]
