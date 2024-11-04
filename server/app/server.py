from fastapi import FastAPI, HTTPException, Depends, status, Form  # type: ignore
from fastapi.security import OAuth2PasswordBearer  # type: ignore
from pydantic import BaseModel  # type: ignore
from typing import Dict
from motor.motor_asyncio import AsyncIOMotorClient  # type: ignore
from bson import ObjectId  # type: ignore
from passlib.context import CryptContext  # type: ignore
from datetime import datetime, timedelta, timezone
import jwt  # type: ignore

app = FastAPI()

MONGO_URL = "mongodb://mongodb:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.parking_system
parking_spots_col = db.parking_spots
reservations_col = db.reservations
users_col = db.users

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT 
SECRET_KEY = "walasjestbardzoprzystojny"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 180

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

CONFIRMATION_TIMEOUT_MINUTES = 2

class PasswordChange(BaseModel):
    current_password: str
    new_password: str

class ParkingSpotStatus(BaseModel):
    parking_spot_id: str
    status: str  # "occupied" or "free"

class ReservationRequest(BaseModel):
    parking_spot_id: str
    action: str  # "reserve" or "cancel"

class ParkingConfirmation(BaseModel):
    parking_spot_id: str

class Token(BaseModel):
    access_token: str
    token_type: str

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_user_by_email(email: str):
    return await users_col.find_one({"email": email})

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Nie udało się zweryfikować poświadczeń",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        if email is None:
            raise credentials_exception
        user = await get_user_by_email(email)
        if user is None:
            raise credentials_exception
        return user
    except jwt.PyJWTError:
        raise credentials_exception

class OAuth2PasswordRequestFormEmail:
    def __init__(
        self,
        email: str = Form(...),
        password: str = Form(...),
        scope: str = Form(""),
        client_id: str = Form(None),
        client_secret: str = Form(None),
    ):
        self.email = email
        self.password = password
        self.scope = scope
        self.client_id = client_id
        self.client_secret = client_secret
        self.scopes = scope.split()

# Authentication
@app.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestFormEmail = Depends()):
    user = await get_user_by_email(form_data.email)
    if not user or not verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/change-password")
async def change_password(
    password_change: PasswordChange,
    current_user: dict = Depends(get_current_user)
):
    if not verify_password(password_change.current_password, current_user["hashed_password"]):
        raise HTTPException(status_code=400, detail="Incorrect current password")
    
    new_hashed_password = get_password_hash(password_change.new_password)
    await users_col.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"hashed_password": new_hashed_password}}
    )
    
    return {"message": "Password updated successfully"}

# Parking management 
@app.post("/update_status")
async def update_parking_spot_status(spot_status: ParkingSpotStatus):
    parking_spot = await parking_spots_col.find_one({"_id": ObjectId(spot_status.parking_spot_id)})
    if not parking_spot:
        raise HTTPException(status_code=404, detail="Parking spot not found")
    
    update_data = {
        "status": spot_status.status,
        "last_status_update": datetime.now(timezone.utc)
    }
    
    if spot_status.status == "occupied":
        # sprawdza czy jest rezerwacja
        reservation = await reservations_col.find_one({
            "parking_spot_id": spot_status.parking_spot_id,
            "active": True
        })
        
        if reservation:
            update_data["waiting_confirmation"] = True
            update_data["color"] = "BLUE"  # jak czeka na potwierdzenie to zmienia na niebieski, ale nie musi

            await reservations_col.update_one(
                {"_id": reservation["_id"]},
                {"$set": {
                    "confirmation_deadline": datetime.now(timezone.utc) + timedelta(minutes=CONFIRMATION_TIMEOUT_MINUTES)
                }}
            )
        else:
            update_data["color"] = "RED"
    else:
        update_data["waiting_confirmation"] = False
        update_data["color"] = "GREEN"
    
    await parking_spots_col.update_one(
        {"_id": ObjectId(spot_status.parking_spot_id)},
        {"$set": update_data}
    )
    
    return {"color": update_data["color"]}

@app.post("/confirm_parking")
async def confirm_parking(
    confirmation: ParkingConfirmation,
    current_user: dict = Depends(get_current_user)
):
    reservation = await reservations_col.find_one({
        "parking_spot_id": confirmation.parking_spot_id,
        "active": True
    })
    
    if not reservation:
        raise HTTPException(status_code=404, detail="No active reservation found for this spot")
    
    if str(reservation["user_id"]) != str(current_user["_id"]):
        raise HTTPException(status_code=403, detail="You are not authorized to confirm this reservation")
    
    if datetime.now(timezone.utc) > reservation["confirmation_deadline"]:
        await reservations_col.update_one(
            {"_id": reservation["_id"]},
            {"$set": {"active": False, "status": "expired"}}
        )
        await parking_spots_col.update_one(
            {"_id": ObjectId(confirmation.parking_spot_id)},
            {"$set": {
                "status": "occupied",
                "color": "RED",
                "waiting_confirmation": False
            }}
        )
        raise HTTPException(status_code=408, detail="Confirmation timeout expired")
    
    await parking_spots_col.update_one(
        {"_id": ObjectId(confirmation.parking_spot_id)},
        {"$set": {
            "status": "occupied",
            "color": "RED",
            "waiting_confirmation": False,
            "confirmed_user_id": str(current_user["_id"])
        }}
    )
    
    await reservations_col.update_one(
        {"_id": reservation["_id"]},
        {"$set": {
            "status": "confirmed",
            "confirmation_time": datetime.now(timezone.utc)
        }}
    )
    
    return {"message": "Parking confirmed successfully"}

@app.post("/reserve")
async def reserve_parking_spot(
    reservation: ReservationRequest,
    current_user: dict = Depends(get_current_user)
):
    parking_spot = await parking_spots_col.find_one({"_id": ObjectId(reservation.parking_spot_id)})
    if not parking_spot:
        raise HTTPException(status_code=404, detail="Parking spot not found")
    
    if reservation.action == "reserve":
        if parking_spot["status"] != "free":
            raise HTTPException(status_code=400, detail="Parking spot is not free")
        
        reservation_doc = {
            "user_id": str(current_user["_id"]),
            "parking_spot_id": reservation.parking_spot_id,
            "active": True,
            "created_at": datetime.now(timezone.utc),
            "status": "reserved"
        }
        await reservations_col.insert_one(reservation_doc)
        
        await parking_spots_col.update_one(
            {"_id": ObjectId(reservation.parking_spot_id)},
            {"$set": {
                "status": "reserved",
                "color": "YELLOW",
                "reserved_user_id": str(current_user["_id"])
            }}
        )
        return {"message": "Parking spot reserved", "color": "YELLOW"}

    elif reservation.action == "cancel":
        active_reservation = await reservations_col.find_one({
            "parking_spot_id": reservation.parking_spot_id,
            "user_id": str(current_user["_id"]),
            "active": True
        })
        
        if not active_reservation:
            raise HTTPException(status_code=400, detail="No active reservation found")
        
        await reservations_col.update_one(
            {"_id": active_reservation["_id"]},
            {"$set": {"active": False, "status": "cancelled"}}
        )
        
        await parking_spots_col.update_one(
            {"_id": ObjectId(reservation.parking_spot_id)},
            {"$set": {
                "status": "free",
                "color": "GREEN",
                "reserved_user_id": None
            }}
        )
        return {"message": "Reservation cancelled", "color": "GREEN"}

@app.get("/parking_status")
async def get_parking_status():
    spots = []
    async for spot in parking_spots_col.find():
        spot_data = {
            "id": str(spot["_id"]),
            "status": spot["status"],
            "color": spot.get("color", "GREEN"),
            "waiting_confirmation": spot.get("waiting_confirmation", False)
        }
        spots.append(spot_data)
    return spots

if __name__ == "__main__":
    import uvicorn  # type: ignore
    uvicorn.run(app, host="0.0.0.0", port=8000)