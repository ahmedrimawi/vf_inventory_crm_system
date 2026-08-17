from pydantic import BaseModel


class ProductCreate(BaseModel):

    name: str
    sku: str
    category: str | None = None

    quantity: float = 0
    min_quantity: float = 0

    purchase_price: float = 0
    selling_price: float = 0

    unit: str = "kg"