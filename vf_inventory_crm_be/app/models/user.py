
import uuid
from typing import Optional

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id : Mapped[uuid.UUID] = mapped_column(
        primary_key=True,
        default=uuid.uuid4
    )

    username : Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False
    )

    email : Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False
    )

    password: Mapped[str] = mapped_column(
        String,
        nullable=False
    )

    full_name : Mapped[Optional[str]] = mapped_column(
        String(255)
    )

    role : Mapped[str] = mapped_column(
        String(50),
        default="user"
    )

    is_active : Mapped[bool] = mapped_column(
        Boolean,
        default=True
    )

    # created_at = Column(
    #     DateTime(timezone=True),
    #     server_default=func.now(),
    # )