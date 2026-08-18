from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.product import Product
from app.models.customer import Customer
from app.models.supplier import Supplier


def get_dashboard_summary(db: Session):

    total_products = (
        db.query(func.count(Product.id))
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    total_stock = (
        db.query(
            func.coalesce(
                func.sum(Product.stock_quantity),
                0,
            )
        )
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    total_customers = (
        db.query(func.count(Customer.id))
        .filter(Customer.is_active.is_(True))
        .scalar()
        or 0
    )

    total_suppliers = (
        db.query(func.count(Supplier.id))
        .filter(Supplier.is_active.is_(True))
        .scalar()
        or 0
    )

    low_stock_products = (
        db.query(Product)
        .filter(
            Product.is_active.is_(True),
            Product.stock_quantity
            <= Product.minimum_stock_level,
        )
        .order_by(
            Product.stock_quantity.asc()
        )
        .all()
    )

    low_stock = [
        {
            "id": product.id,
            "name": product.name,
            "stock_quantity": product.stock_quantity,
            "unit": product.unit,
            "minimum_stock_level":
                product.minimum_stock_level,
        }
        for product in low_stock_products
    ]

    return {
        "total_products": total_products,
        "total_stock": total_stock,
        "total_customers": total_customers,
        "total_suppliers": total_suppliers,
        "low_stock": low_stock,
    }