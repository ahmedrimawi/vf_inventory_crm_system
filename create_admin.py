from app.database import SessionLocal
from app.models import User
from app.security import hash_password


db = SessionLocal()

try:

    username = "admin"
    email = "admin@example.com"
    password = "Admin123!"

    existing_user = (
        db.query(User)
        .filter(User.username == username)
        .first()
    )

    if existing_user:
        print("Admin user already exists")

    else:

        user = User(
            username=username,
            email=email,
            password=hash_password(password),
            full_name="System Administrator",
            role="admin",
            is_active=True,
        )

        db.add(user)
        db.commit()

        print("Admin user created successfully")
        print("Username:", username)
        print("Password:", password)

finally:
    db.close()