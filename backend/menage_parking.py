import argparse
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorClient
from prettytable import PrettyTable
import string
import asyncio

# MongoDB connection
client = AsyncIOMotorClient("mongodb://localhost:27017")
db = client.parking_system
parking_spots_col = db.parking_spots

def generate_pretty_id(floor: int, spot_number: int) -> str:
    section = string.ascii_uppercase[floor - 1]
    return f"{section}{spot_number}"

async def add_parking_spot(status: str, color: str, floor: int, spot_number: int):
    pretty_id = generate_pretty_id(floor, spot_number)
    # Check if spot already exists
    existing = await parking_spots_col.find_one({"pretty_id": pretty_id})
    if existing:
        print(f"Parking spot with ID {pretty_id} already exists!")
        return

    spot = {
        "status": status,
        "color": color,
        "floor": floor,
        "spot_number": spot_number,
        "pretty_id": pretty_id,
        "created_at": datetime.utcnow(),
        "last_modified": datetime.utcnow()
    }
    result = await parking_spots_col.insert_one(spot)
    print(f"Added parking spot with ID: {pretty_id}")

async def list_parking_spots():
    table = PrettyTable()
    table.field_names = ["Pretty ID", "Status", "Color", "Floor", "Created At"]

    async for spot in parking_spots_col.find():
        # Use get() method with defaults for safety
        table.add_row([
            spot.get("pretty_id", "N/A"),
            spot.get("status", "unknown"),
            spot.get("color", "unknown"),
            spot.get("floor", "unknown"),
            spot.get("created_at", datetime.utcnow()).strftime("%Y-%m-%d %H:%M:%S")
        ])

    print("\nParking Spot List:")
    print(table)

async def delete_parking_spot(pretty_id: str):
    result = await parking_spots_col.delete_one({"pretty_id": pretty_id})
    if result.deleted_count:
        print(f"Successfully deleted parking spot with ID: {pretty_id}")
    else:
        print(f"Parking spot with ID: {pretty_id} not found")

async def update_parking_spot(pretty_id: str, status: str, color: str):
    result = await parking_spots_col.update_one(
        {"pretty_id": pretty_id},
        {
            "$set": {
                "status": status,
                "color": color,
                "last_modified": datetime.utcnow()
            }
        }
    )
    if result.modified_count:
        print(f"Successfully updated parking spot with ID: {pretty_id}")
    else:
        print(f"Parking spot with ID: {pretty_id} not found or no changes made")

async def main():
    parser = argparse.ArgumentParser(description='Parking System Parking Spot Management')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Add parking spot command
    add_parser = subparsers.add_parser('add', help='Add a new parking spot')
    add_parser.add_argument('status', help='Initial status (free, reserved, occupied)')
    add_parser.add_argument('color', help='Color representation')
    add_parser.add_argument('floor', type=int, help='Floor number (1-26)')
    add_parser.add_argument('spot_number', type=int, help='Spot number on the floor')

    # List parking spots command
    subparsers.add_parser('list', help='List all parking spots')

    # Delete parking spot command
    delete_parser = subparsers.add_parser('delete', help='Delete a parking spot')
    delete_parser.add_argument('pretty_id', help='Pretty ID of the spot (e.g. A1)')

    # Update parking spot command
    update_parser = subparsers.add_parser('update', help='Update a parking spot')
    update_parser.add_argument('pretty_id', help='Pretty ID of the spot (e.g. A1)')
    update_parser.add_argument('status', help='New status (free, reserved, occupied)')
    update_parser.add_argument('color', help='New color representation')

    args = parser.parse_args()

    if args.command == 'add':
        if not 1 <= args.floor <= 26:
            print("Floor must be between 1 and 26")
            return
        await add_parking_spot(args.status, args.color, args.floor, args.spot_number)
    elif args.command == 'list':
        await list_parking_spots()
    elif args.command == 'delete':
        await delete_parking_spot(args.pretty_id)
    elif args.command == 'update':
        await update_parking_spot(args.pretty_id, args.status, args.color)
    else:
        parser.print_help()

if __name__ == "__main__":
    asyncio.run(main())