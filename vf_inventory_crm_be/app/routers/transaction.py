from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.transaction import (
    TransactionCreate,
    TransactionResponse,
)
from app.services.transaction_service import (
    create_transaction,
)
from app.models.transaction import Transaction


router = APIRouter(
    prefix="/transactions",
    tags=["Transactions"],
)


@router.post(
    "/",
    response_model=TransactionResponse,
)
def create_transaction_endpoint(
    data: TransactionCreate,
    db: Session = Depends(get_db),
):

    try:

        return create_transaction(
            db,
            data,
        )

    except HTTPException:
        db.rollback()
        raise

    except Exception as e:
        db.rollback()

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


@router.get(
    "/",
)
def get_transactions(
    db: Session = Depends(get_db),
):

    transactions = (
        db.query(Transaction)
        .order_by(
            Transaction.transaction_date.desc()
        )
        .all()
    )

    return transactions