import asyncio
from motor.motor_asyncio import AsyncIOMotorClient  # type: ignore
from passlib.context import CryptContext  # type: ignore
from datetime import datetime
import argparse
from prettytable import PrettyTable  # type: ignore
from bson import ObjectId  # type: ignore


MONGO_URL = "mongodb://localhost:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.parking_system
users_col = db.users

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

async def add_user(username: str, full_name: str, email: str, password: str, is_admin: bool = False) -> bool:
    existing_user = await users_col.find_one({"username": username})
    if existing_user:
        print(f"Error: User '{username}' already exists")
        return False

    existing_email = await users_col.find_one({"email": email})
    if existing_email:
        print(f"Error: Email '{email}' is already registered")
        return False

    user_doc = {
        "username": username,
        "email": email,
        "full_name": full_name,
        "hashed_password": hash_password(password),
        "is_admin": is_admin,
        "created_at": datetime.utcnow(),
        "last_modified": datetime.utcnow()
    }

    try:
        result = await users_col.insert_one(user_doc)
        print(f"Successfully created user '{username}' with ID: {result.inserted_id}")
        return True
    except Exception as e:
        print(f"Error creating user: {e}")
        return False

async def list_users():
    table = PrettyTable()
    table.field_names = ["Username", "Full Name", "Email", "Admin", "Created At"]

    async for user in users_col.find():
        table.add_row([
            user.get("username", "N/A"),
            user.get("full_name", "N/A"),
            user.get("email", "N/A"),
            "Yes" if user.get("is_admin") else "No",
            user.get("created_at", datetime.utcnow()).strftime("%Y-%m-%d %H:%M:%S")
        ])

    print("\nUser List:")
    print(table)

async def update_user(username: str, full_name: str = None, email: str = None):
    update_data = {"last_modified": datetime.utcnow()}
    if full_name:
        update_data["full_name"] = full_name
    if email:
        existing_email = await users_col.find_one({"email": email})
        if existing_email and existing_email["username"] != username:
            print(f"Error: Email '{email}' is already registered")
            return False
        update_data["email"] = email

    result = await users_col.update_one(
        {"username": username},
        {"$set": update_data}
    )
    
    if result.modified_count:
        print(f"Successfully updated user '{username}'")
        return True
    print(f"User '{username}' not found")
    return False

async def delete_user(username: str):
    result = await users_col.delete_one({"username": username})
    if result.deleted_count:
        print(f"Successfully deleted user '{username}'")
        return True
    print(f"User '{username}' not found")
    return False

async def main():
    parser = argparse.ArgumentParser(description='User Management System')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Add user command
    add_parser = subparsers.add_parser('add', help='Add a new user')
    add_parser.add_argument('username', help='Username')
    add_parser.add_argument('full_name', help='Full name')
    add_parser.add_argument('email', help='Email address')
    add_parser.add_argument('password', help='Password')
    add_parser.add_argument('--admin', action='store_true', help='Make user an admin')

    # List users command
    subparsers.add_parser('list', help='List all users')

    # Update user command
    update_parser = subparsers.add_parser('update', help='Update a user')
    update_parser.add_argument('username', help='Username to update')
    update_parser.add_argument('--full_name', help='New full name')
    update_parser.add_argument('--email', help='New email')

    # Delete user command
    delete_parser = subparsers.add_parser('delete', help='Delete a user')
    delete_parser.add_argument('username', help='Username to delete')

    args = parser.parse_args()

    if args.command == 'add':
        await add_user(args.username, args.full_name, args.email, args.password, args.admin)
    elif args.command == 'list':
        await list_users()
    elif args.command == 'update':
        await update_user(args.username, args.full_name, args.email)
    elif args.command == 'delete':
        await delete_user(args.username)
    else:
        parser.print_help()

if __name__ == "__main__":
    asyncio.run(main())