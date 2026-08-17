from app.database import Base, SessionLocal, engine
from app.models.user import User
from app.services.auth_service import hash_password


Base.metadata.create_all(bind=engine)

db = SessionLocal()

try:

    user = User(
        username="admin",
        email="admin@example.com",
        full_name="System Administrator",
        password=hash_password("Admin@123"),
        role="admin",
        is_active=True,
    )

    db.add(user)
    db.commit()

    print("Admin user created successfully.")

except Exception as e:

    db.rollback()

    print("Error:", e)

finally:

    db.close()