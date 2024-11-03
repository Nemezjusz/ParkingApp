import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from datetime import datetime
import argparse
from prettytable import PrettyTable
from bson import ObjectId


MONGO_URL = "mongodb://localhost:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.parking_system
users_col = db.users

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

async def add_user(username: str, email: str, password: str, is_admin: bool = False) -> bool:
   
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
    table.field_names = ["ID", "Username", "Email", "Admin", "Created At"]
    
    async for user in users_col.find():
        table.add_row([
            str(user["_id"]),
            user["username"],
            user["email"],
            "Yes" if user.get("is_admin", False) else "No",
            user["created_at"].strftime("%Y-%m-%d %H:%M:%S")
        ])
    
    print("\nUser List:")
    print(table)

async def delete_user(username: str):
    result = await users_col.delete_one({"username": username})
    if result.deleted_count:
        print(f"Successfully deleted user '{username}'")
    else:
        print(f"User '{username}' not found")

async def change_password(username: str, new_password: str):
    result = await users_col.update_one(
        {"username": username},
        {
            "$set": {
                "hashed_password": hash_password(new_password),
                "last_modified": datetime.utcnow()
            }
        }
    )
    if result.modified_count:
        print(f"Successfully updated password for user '{username}'")
    else:
        print(f"User '{username}' not found")

async def make_admin(username: str, admin_status: bool):
    result = await users_col.update_one(
        {"username": username},
        {
            "$set": {
                "is_admin": admin_status,
                "last_modified": datetime.utcnow()
            }
        }
    )
    if result.modified_count:
        status = "admin" if admin_status else "regular user"
        print(f"Successfully set user '{username}' as {status}")
    else:
        print(f"User '{username}' not found")

async def main():
    parser = argparse.ArgumentParser(description='Parking System User Management')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Add user command
    add_parser = subparsers.add_parser('add', help='Add a new user')
    add_parser.add_argument('username', help='Username')
    add_parser.add_argument('email', help='Email address')
    add_parser.add_argument('password', help='Password')
    add_parser.add_argument('--admin', action='store_true', help='Make user an admin')

    # List users command
    subparsers.add_parser('list', help='List all users')

    # Delete user command
    delete_parser = subparsers.add_parser('delete', help='Delete a user')
    delete_parser.add_argument('username', help='Username to delete')

    # Change password command
    passwd_parser = subparsers.add_parser('passwd', help='Change user password')
    passwd_parser.add_argument('username', help='Username')
    passwd_parser.add_argument('password', help='New password')

    # Make admin command
    admin_parser = subparsers.add_parser('admin', help='Change admin status')
    admin_parser.add_argument('username', help='Username')
    admin_parser.add_argument('--remove', action='store_true', help='Remove admin status')

    args = parser.parse_args()

    if args.command == 'add':
        await add_user(args.username, args.email, args.password, args.admin)
    elif args.command == 'list':
        await list_users()
    elif args.command == 'delete':
        await delete_user(args.username)
    elif args.command == 'passwd':
        await change_password(args.username, args.password)
    elif args.command == 'admin':
        await make_admin(args.username, not args.remove)
    else:
        parser.print_help()

if __name__ == "__main__":
    asyncio.run(main())