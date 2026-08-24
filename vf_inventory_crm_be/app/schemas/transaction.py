from datetime import datetime
from decimal import Decimal
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class TransactionItemCreate(BaseModel):
    product_id: UUID

    quantity: Decimal = Field(
        gt=0
    )

    unit_price: Decimal = Field(
        ge=0
    )


class TransactionCreate(BaseModel):
    transaction_type: str

    customer_id: Optional[UUID] = None

    supplier_id: Optional[UUID] = None

    notes: Optional[str] = None

    items: list[TransactionItemCreate]


class TransactionUpdate(BaseModel):
    transaction_type: Optional[str] = None

    customer_id: Optional[UUID] = None

    supplier_id: Optional[UUID] = None

    notes: Optional[str] = None

    status: Optional[str] = None

    items: Optional[list[TransactionItemCreate]] = None


class TransactionItemResponse(BaseModel):
    id: UUID
    product_id: UUID
    quantity: Decimal
    unit_price: Decimal
    total_price: Decimal

    class Config:
        from_attributes = True


class TransactionResponse(BaseModel):
    id: UUID
    transaction_number: str
    transaction_type: str

    customer_id: Optional[UUID]
    supplier_id: Optional[UUID]

    transaction_date: datetime
    total_amount: Decimal
    status: str
    notes: Optional[str]

    items: list[TransactionItemResponse]

    class Config:
        from_attributes = True