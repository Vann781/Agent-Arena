import firebase_admin
from firebase_admin import credentials, firestore

from backend.config import settings

_app = None
_db = None


def _get_app():
    global _app
    if _app is None:
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
        _app = firebase_admin.initialize_app(cred)
    return _app


def get_db():
    global _db
    if _db is None:
        _get_app()
        _db = firestore.client()
    return _db


def create_document(collection: str, doc_id: str, data: dict) -> None:
    get_db().collection(collection).document(doc_id).set(data)


def get_document(collection: str, doc_id: str) -> dict | None:
    doc = get_db().collection(collection).document(doc_id).get()
    return doc.to_dict() if doc.exists else None


def update_document(collection: str, doc_id: str, data: dict) -> None:
    get_db().collection(collection).document(doc_id).update(data)


def query_collection(collection: str, order_by: str | None = None, limit: int = 50) -> list[dict]:
    ref = get_db().collection(collection)
    if order_by:
        ref = ref.order_by(order_by, direction=firestore.Query.DESCENDING)
    docs = ref.limit(limit).stream()
    return [{**d.to_dict(), "id": d.id} for d in docs]
