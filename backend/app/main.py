from fastapi import FastAPI, UploadFile, File, HTTPException
from PIL import Image
from io import BytesIO
from fastapi.middleware.cors import CORSMiddleware

from pathlib import Path
import joblib
import pandas as pd
from pydantic import BaseModel, Field

from app.logic import (
    predict_disease,
    predict_crop,
    get_weather,
    calculate_irrigation,
    get_irrigation_recommendation,
    ask_farming_assistant,
    ask_context_farming_assistant,
    predict_soil
)

# Load the trained fertilizer recommendation model
BASE_DIR = Path(__file__).resolve().parents[1]

FERTILIZER_MODEL_PATH = (
    BASE_DIR / "models" / "fertilizer_model"
    / "fertilizer_model.joblib"
)

fertilizer_model = joblib.load(FERTILIZER_MODEL_PATH) 
app = FastAPI(
    title="Smart Farming Assistant API",
    description="AI-powered farming backend",
    version="1.0"
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://127.0.0.1",
        "https://smart-farming-assistant-web.onrender.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/weather")
async def weather(
    latitude: float,
    longitude: float
):

    result = get_weather(
        latitude=latitude,
        longitude=longitude
    )

    return result


@app.get("/")
def home():
    return {
        "message": "Smart Farming Assistant API is running"
    }


@app.get("/healthz")
def health_check():
    return {"status": "healthy"}


@app.post("/irrigation/auto")
async def automatic_irrigation(
    latitude: float,
    longitude: float,
    crop: str,
    area: float,
    irrigation_efficiency: float = 0.80
):
    try:
        result = get_irrigation_recommendation(
            latitude=latitude,
            longitude=longitude,
            crop=crop,
            area=area,
            irrigation_efficiency=irrigation_efficiency
        )

        return result

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

@app.post("/predict/disease")
async def disease_prediction(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()

        if not image_bytes:
            raise HTTPException(
                status_code=400,
                detail="The uploaded image is empty."
            )

        result = predict_disease(image_bytes)
        return result

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Disease detection error: {str(e)}"
        )

@app.post("/predict/crop")
async def crop_prediction(
    n: float,
    p: float,
    k: float,
    temperature: float,
    humidity: float,
    ph: float,
    rainfall: float
):

    result = predict_crop(
        n=n,
        p=p,
        k=k,
        temperature=temperature,
        humidity=humidity,
        ph=ph,
        rainfall=rainfall
    )

    return result

@app.post("/irrigation/recommend")
async def irrigation_recommendation(
    crop: str,
    et0: float,
    rainfall: float,
    area: float,
    irrigation_efficiency: float = 0.80
):
    try:
        result = calculate_irrigation(
            crop=crop,
            et0=et0,
            rainfall=rainfall,
            area=area,
            irrigation_efficiency=irrigation_efficiency
        )

        return result

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

#chatbot endpoint

@app.post("/assistant/chat")
def farming_assistant(message: str):
    try:
        response = ask_farming_assistant(message)

        return {
            "message": message,
            "response": response
        }

    except Exception as e:
        print(f"AI assistant error: {type(e).__name__}: {e}", flush=True)
        raise HTTPException(
            status_code=502,
            detail="The AI assistant is temporarily unavailable. Please try again."
        )

@app.post("/assistant/context-chat")
async def context_farming_assistant(
    message: str,
    crop: str,
    latitude: float,
    longitude: float,
    area: float
):
    try:
        result = ask_context_farming_assistant(
            message=message,
            crop=crop,
            latitude=latitude,
            longitude=longitude,
            area=area
        )

        return result

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    except Exception as e:
    import traceback
    print("CONTEXT CHAT ERROR:", repr(e), flush=True)
    traceback.print_exc()
    raise HTTPException(
        status_code=500,
        detail="The farming assistant could not process your question."
    )

    

from fastapi import UploadFile, File, HTTPException
from PIL import Image, UnidentifiedImageError
from io import BytesIO

@app.post("/predict/soil")
async def predict_soil_endpoint(file: UploadFile = File(...)):
    filename = file.filename or ""

    if not filename.lower().endswith(
        (".jpg", ".jpeg", ".png", ".webp", ".bmp")
    ):
        raise HTTPException(
            status_code=400,
            detail="Please upload a supported image file."
        )

    try:
        image_bytes = await file.read()
        image = Image.open(BytesIO(image_bytes))
        image.load()

        result = predict_soil(image)
        return result

    except (UnidentifiedImageError, OSError):
        raise HTTPException(
            status_code=400,
            detail="The uploaded file could not be read as an image."
        )

    
class FertilizerRequest(BaseModel):
    temperature: float = Field(ge=-10, le=60)
    humidity: float = Field(ge=0, le=100)
    moisture: float = Field(ge=0, le=100)
    soil_type: str
    crop_type: str

    nitrogen: float = Field(ge=0)
    potassium: float = Field(ge=0)
    phosphorus: float = Field(ge=0)


@app.post("/recommend/fertilizer")
def recommend_fertilizer(request: FertilizerRequest):
    try:
        input_data = pd.DataFrame([{
            "Temperature": request.temperature,
            "Humidity": request.humidity,
            "Moisture": request.moisture,
            "Soil Type": request.soil_type.strip(),
            "Crop Type": request.crop_type.strip(),
            "Nitrogen": request.nitrogen,
            "Potassium": request.potassium,
            "Phosphorus": request.phosphorus
        }])

        prediction = fertilizer_model.predict(input_data)[0]

        return {
            "fertilizer_name": str(prediction),
            "crop_type": request.crop_type,
            "soil_type": request.soil_type,
            "message": (
                "This is a model prediction based on the training "
                "dataset. Confirm fertilizer choice and application "
                "rate using a soil test and local agricultural guidance."
            )
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail="Unable to generate fertilizer recommendation."
        ) from exc