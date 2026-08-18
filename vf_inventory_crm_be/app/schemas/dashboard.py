# from decimal import Decimal
# from uuid import UUID

# from pydantic import BaseModel


# class LowStockProduct(BaseModel):
#     id: UUID
#     name: str
#     stock_quantity: Decimal
#     unit: str
#     minimum_stock_level: Decimal


# class DashboardSummary(BaseModel):
#     total_products: int
#     total_stock: Decimal
#     total_customers: int
#     total_suppliers: int
#     low_stock: list[LowStockProduct]

from uuid import UUID

from pydantic import BaseModel


class LowStockProduct(BaseModel):
    id: UUID
    name: str
    stock_quantity: float
    unit: str
    minimum_stock_level: float


class DashboardSummary(BaseModel):
    total_products: int
    total_stock: float
    total_customers: int
    total_suppliers: int
    low_stock: list[LowStockProduct]