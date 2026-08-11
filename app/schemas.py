from pydantic import BaseModel
from typing import Optional

class LoginRequest(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: Optional[str]
    role: str
    is_active: bool


class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse