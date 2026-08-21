import uuid
from decimal import Decimal

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.product import Product
from app.models.customer import Customer
from app.models.supplier import Supplier
from app.models.transaction import Transaction
from app.models.transaction_item import TransactionItem
from app.schemas.transaction import TransactionCreate


def create_transaction(
    db: Session,
    data: TransactionCreate,
):

    if data.transaction_type not in (
        "sale",
        "purchase",
    ):
        raise HTTPException(
            status_code=400,
            detail="Invalid transaction type",
        )

    if not data.items:
        raise HTTPException(
            status_code=400,
            detail="Transaction must contain at least one product",
        )

    # -------------------------
    # Validate party
    # -------------------------

    if data.transaction_type == "sale":

        if not data.customer_id:
            raise HTTPException(
                status_code=400,
                detail="Customer is required for a sale",
            )

        customer = (
            db.query(Customer)
            .filter(Customer.id == data.customer_id)
            .first()
        )

        if not customer:
            raise HTTPException(
                status_code=404,
                detail="Customer not found",
            )

        if not customer.is_active:
            raise HTTPException(
                status_code=400,
                detail="Customer is inactive",
            )

    else:

        if not data.supplier_id:
            raise HTTPException(
                status_code=400,
                detail="Supplier is required for a purchase",
            )

        supplier = (
            db.query(Supplier)
            .filter(Supplier.id == data.supplier_id)
            .first()
        )

        if not supplier:
            raise HTTPException(
                status_code=404,
                detail="Supplier not found",
            )

        if not supplier.is_active:
            raise HTTPException(
                status_code=400,
                detail="Supplier is inactive",
            )

    # -------------------------
    # Generate number
    # -------------------------

    prefix = (
        "SALE"
        if data.transaction_type == "sale"
        else "PUR"
    )

    transaction_number = (
        f"{prefix}-{uuid.uuid4().hex[:8].upper()}"
    )

    # -------------------------
    # Create transaction
    # -------------------------

    transaction = Transaction(
        transaction_number=transaction_number,
        transaction_type=data.transaction_type,
        customer_id=data.customer_id,
        supplier_id=data.supplier_id,
        notes=data.notes,
        status="completed",
        total_amount=Decimal("0"),
    )

    db.add(transaction)

    db.flush()

    total_amount = Decimal("0")

    # -------------------------
    # Process products
    # -------------------------

    for item in data.items:

        product = (
            db.query(Product)
            .filter(
                Product.id == item.product_id,
                Product.is_active.is_(True),
            )
            .with_for_update()
            .first()
        )

        if not product:
            raise HTTPException(
                status_code=404,
                detail=f"Product {item.product_id} not found",
            )

        quantity = Decimal(str(item.quantity))

        unit_price = Decimal(
            str(item.unit_price)
        )

        # -------------------------
        # SALE
        # -------------------------

        if data.transaction_type == "sale":

            current_stock = Decimal(
                str(product.stock_quantity or 0)
            )

            if current_stock < quantity:

                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Insufficient stock for "
                        f"{product.name}. "
                        f"Available: {current_stock} "
                        f"{product.unit}"
                    ),
                )

            product.stock_quantity = (
                current_stock - quantity
            )

        # -------------------------
        # PURCHASE
        # -------------------------

        else:

            current_stock = Decimal(
                str(product.stock_quantity or 0)
            )

            product.stock_quantity = (
                current_stock + quantity
            )

        # -------------------------
        # Line item
        # -------------------------

        line_total = quantity * unit_price

        transaction_item = TransactionItem(
            transaction_id=transaction.id,
            product_id=product.id,
            quantity=quantity,
            unit_price=unit_price,
        )

        db.add(transaction_item)

        total_amount += line_total

    transaction.total_amount = total_amount

    db.commit()

    db.refresh(transaction)

    return transaction