import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class SupplierBase(BaseModel):
    name: str

    contact_person: Optional[str] = None

    phone: Optional[str] = None

    email: Optional[str] = None

    address: Optional[str] = None

    is_active: bool = True


class SupplierCreate(SupplierBase):
    pass


class SupplierUpdate(BaseModel):
    name: Optional[str] = None

    contact_person: Optional[str] = None

    phone: Optional[str] = None

    email: Optional[str] = None

    address: Optional[str] = None

    is_active: Optional[bool] = None


class SupplierResponse(SupplierBase):
    id: uuid.UUID

    created_at: datetime

    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True
    )