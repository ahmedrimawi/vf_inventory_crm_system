import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, ConfigDict


class ProductBase(BaseModel):
    name: str

    sku: Optional[str] = None

    category: Optional[str] = None

    description: Optional[str] = None

    unit: str = "piece"

    purchase_price: Decimal = Decimal("0")

    selling_price: Decimal = Decimal("0")

    stock_quantity: Decimal = Decimal("0")

    minimum_stock_level: Decimal = Decimal("10")

    supplier_id: Optional[uuid.UUID] = None

    is_active: bool = True


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: Optional[str] = None

    sku: Optional[str] = None

    category: Optional[str] = None

    description: Optional[str] = None

    unit: Optional[str] = None

    purchase_price: Optional[Decimal] = None

    selling_price: Optional[Decimal] = None

    stock_quantity: Optional[Decimal] = None

    minimum_stock_level: Optional[Decimal] = None

    supplier_id: Optional[uuid.UUID] = None

    is_active: Optional[bool] = None


class ProductResponse(ProductBase):
    id: uuid.UUID

    created_at: datetime

    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True
    )