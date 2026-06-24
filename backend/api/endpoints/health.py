from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
def health_check():
    return {"status": "ok"}


@router.get("/")
def root():
    return {"app": "Agent Arena", "version": "1.0.0", "status": "running"}
