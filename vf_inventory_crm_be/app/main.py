from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers import auth, product, customer, supplier
from app.routers import dashboard
from app.routers import transaction


app = FastAPI(
    title="VF Inventory CRM API",
    version="1.0.0"
)

origins = [
    "http://localhost:56943",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]


# CORS - temporary development configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=origins,
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth.router)
app.include_router(product.router)
app.include_router(supplier.router)
app.include_router(customer.router)
app.include_router(dashboard.router)
app.include_router(transaction.router)


@app.get("/")
def root():
    return {
        "message": "VF Inventory CRM API is running"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }


Base.metadata.create_all(bind=engine)