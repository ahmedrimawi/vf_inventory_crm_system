import uuid

from sqlalchemy import Numeric, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Product(Base):

    __tablename__ = "products"

    id: Mapped[uuid.UUID] = mapped_column(
        primary_key=True,
        default=uuid.uuid4
    )

    name: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )

    sku: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False
    )

    category: Mapped[str | None] = mapped_column(
        String(100)
    )

    quantity: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    min_quantity: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    purchase_price: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    selling_price: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    unit: Mapped[str] = mapped_column(
        String(50),
        default="kg"
    )