import asyncio
from motor.motor_asyncio import AsyncIOMotorClient  # type: ignore
from datetime import datetime
import argparse
from prettytable import PrettyTable  # type: ignore
from bson import ObjectId  # type: ignore


MONGO_URL = "mongodb://localhost:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.parking_system
parking_spots_col = db.parking_spots

async def add_parking_spot(status: str, color: str) -> bool:
    
    parking_spot_doc = {
        "status": status,
        "color": color,
        "created_at": datetime.utcnow(),
        "last_modified": datetime.utcnow()
    }

    try:
        result = await parking_spots_col.insert_one(parking_spot_doc)
        print(f"Successfully created parking spot with ID: {result.inserted_id}")
        return True
    except Exception as e:
        print(f"Error creating parking spot: {e}")
        return False

async def list_parking_spots():
    table = PrettyTable()
    table.field_names = ["ID", "Status", "Color", "Created At"]

    async for spot in parking_spots_col.find():
        table.add_row([
            str(spot["_id"]),
            spot["status"],
            spot["color"],
            spot["created_at"].strftime("%Y-%m-%d %H:%M:%S")
        ])

    print("\nParking Spot List:")
    print(table)

async def delete_parking_spot(spot_id: str):
    result = await parking_spots_col.delete_one({"_id": ObjectId(spot_id)})
    if result.deleted_count:
        print(f"Successfully deleted parking spot with ID: {spot_id}")
    else:
        print(f"Parking spot with ID: {spot_id} not found")

async def update_parking_spot(spot_id: str, status: str, color: str):
    result = await parking_spots_col.update_one(
        {"_id": ObjectId(spot_id)},
        {
            "$set": {
                "status": status,
                "color": color,
                "last_modified": datetime.utcnow()
            }
        }
    )
    if result.modified_count:
        print(f"Successfully updated parking spot with ID: {spot_id}")
    else:
        print(f"Parking spot with ID: {spot_id} not found or no changes made")

async def main():
    parser = argparse.ArgumentParser(description='Parking System Parking Spot Management')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Add parking spot command
    add_parser = subparsers.add_parser('add', help='Add a new parking spot')
    add_parser.add_argument('status', help='Initial status of the parking spot (free, reserved, occupied)')
    add_parser.add_argument('color', help='Color representation of the parking spot')

    # List parking spots command
    subparsers.add_parser('list', help='List all parking spots')

    # Delete parking spot command
    delete_parser = subparsers.add_parser('delete', help='Delete a parking spot')
    delete_parser.add_argument('spot_id', help='ID of the parking spot to delete')

    # Update parking spot command
    update_parser = subparsers.add_parser('update', help='Update a parking spot status and color')
    update_parser.add_argument('spot_id', help='ID of the parking spot to update')
    update_parser.add_argument('status', help='New status of the parking spot (free, reserved, occupied)')
    update_parser.add_argument('color', help='New color representation of the parking spot')

    args = parser.parse_args()

    if args.command == 'add':
        await add_parking_spot(args.status, args.color)
    elif args.command == 'list':
        await list_parking_spots()
    elif args.command == 'delete':
        await delete_parking_spot(args.spot_id)
    elif args.command == 'update':
        await update_parking_spot(args.spot_id, args.status, args.color)
    else:
        parser.print_help()

if __name__ == "__main__":
    asyncio.run(main())


