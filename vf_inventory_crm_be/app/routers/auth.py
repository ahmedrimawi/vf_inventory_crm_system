from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.user import LoginRequest, LoginResponse
from app.services.auth_service import (
    create_access_token,
    verify_password,
)


router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)


@router.post("/login", response_model=LoginResponse)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db)
):
    print("LOGIN USERNAME:", repr(request.username))
    print("LOGIN PASSWORD RECEIVED:", bool(request.password))

    user = (
        db.query(User)
        .filter(User.username == request.username)
        .first()
    )

    print("USER FOUND:", user is not None)

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    print("USER ID:", user.id)
    print("USER ACTIVE:", user.is_active)
    print("PASSWORD HASH EXISTS:", bool(user.password_hash))

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="User account is disabled"
        )

    password_valid = verify_password(
        request.password,
        user.password_hash
    )

    print("PASSWORD VALID:", password_valid)

    if not password_valid:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    token = create_access_token(str(user.id))

    return LoginResponse(
        access_token=token,
        token_type="bearer",
        user_id=str(user.id),
        username=user.username,
        full_name=user.full_name,
        role=user.role,
        is_active=user.is_active,
    )