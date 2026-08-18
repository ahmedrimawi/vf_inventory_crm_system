from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers import auth


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="VF Inventory CRM API",
    version="1.0.0"
)


# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:8000",
        "http://localhost:xxxx",
        "http://localhost:63611",
        "http://localhost:56506",
        "https://vf-inventory-crm-frontend.onrender.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth.router)


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