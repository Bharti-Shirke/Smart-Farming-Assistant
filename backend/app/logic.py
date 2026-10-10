import os
from dotenv import load_dotenv
from google import genai
from pathlib import Path
import json
import io
import pickle
import requests

import numpy as np
import tensorflow as tf
from PIL import Image


# Path to the trained model
BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = BASE_DIR / "models" / "disease_model" / "disease_model_final.keras"
LABELS_PATH = BASE_DIR / "models" / "disease_model" / "class_names.json"

#api key for chatbot
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

gemini_client = genai.Client(
    api_key=GEMINI_API_KEY
)

# Load model
model = tf.keras.models.load_model(MODEL_PATH)

# Load class names
with open(LABELS_PATH, "r", encoding="utf-8") as f:
    class_names = json.load(f)


def predict_disease(image_bytes: bytes):

    # Open uploaded image
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # Resize to model input size
    image = image.resize((224, 224))

    # Convert image to numpy array
    image_array = np.array(image, dtype=np.float32)

    # Add batch dimension
    image_array = np.expand_dims(image_array, axis=0)

    # Predict
    predictions = model.predict(image_array, verbose=0)

    # Get highest probability
    predicted_index = np.argmax(predictions[0])
    confidence = float(predictions[0][predicted_index])

    # Get disease name
    disease = class_names[predicted_index]

    # Extract crop name
    crop = disease.split("___")[0]

    return {
        "disease": disease,
        "confidence": round(confidence, 4),
        "crop": crop
    }

# --------------------------------------------------
# CROP RECOMMENDATION MODEL
# --------------------------------------------------

CROP_MODEL_PATH = (
    BASE_DIR
    / "models"
    / "crop_model"
    / "crop_model.pkl"
)

with open(CROP_MODEL_PATH, "rb") as file:
    crop_model = pickle.load(file)


def predict_crop(
    n: float,
    p: float,
    k: float,
    temperature: float,
    humidity: float,
    ph: float,
    rainfall: float
):

    # Create input in the same order used during training
    input_data = np.array([[
        n,
        p,
        k,
        temperature,
        humidity,
        ph,
        rainfall
    ]])

    # Predict crop
    prediction = crop_model.predict(input_data)[0]

    # Get prediction probabilities
    probabilities = crop_model.predict_proba(input_data)[0]

    # Highest probability
    confidence = float(np.max(probabilities))

    return {
        "recommended_crop": prediction,
        "confidence": round(confidence, 4)
    }

# --------------------------------------------------
# WEATHER API
# --------------------------------------------------

WEATHER_API_URL = "https://api.open-meteo.com/v1/forecast"


def get_weather(latitude: float, longitude: float):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "apparent_temperature,"
            "precipitation,"
            "weather_code,"
            "wind_speed_10m"
        ),
        "daily": (
            "temperature_2m_max,"
            "temperature_2m_min,"
            "precipitation_sum,"
            "et0_fao_evapotranspiration"
        ),
        "forecast_days": 7,
        "timezone": "auto"
    }

    response = requests.get(
        WEATHER_API_URL,
        params=params,
        timeout=10
    )

    response.raise_for_status()

    data = response.json()

    current = data["current"]
    daily = data["daily"]

    return {
        "location": {
            "latitude": latitude,
            "longitude": longitude
        },

        "current": {
            "temperature": current["temperature_2m"],
            "humidity": current["relative_humidity_2m"],
            "apparent_temperature": current["apparent_temperature"],
            "precipitation": current["precipitation"],
            "wind_speed": current["wind_speed_10m"],
            "weather_code": current["weather_code"]
        },

        "forecast": {
            "dates": daily["time"],
            "max_temperature": daily["temperature_2m_max"],
            "min_temperature": daily["temperature_2m_min"],
            "precipitation": daily["precipitation_sum"],
            "reference_et0": daily["et0_fao_evapotranspiration"]
        }
    }


CROP_KC = {
    "rice": 1.10,
    "maize": 1.20,
    "wheat": 1.15,
    "cotton": 1.15,
    "sugarcane": 1.25,
    "tomato": 1.15,
    "potato": 1.10,
    "banana": 1.10,
    "apple": 1.00,
    "blackgram": 1.00,
    "chickpea": 1.00,
    "coconut": 1.00,
    "coffee": 1.00,
    "grapes": 1.00,
    "jute": 1.10,
    "kidneybeans": 1.00,
    "lentil": 1.00,
    "mango": 1.00,
    "mothbeans": 1.00,
    "mungbean": 1.00,
    "muskmelon": 1.00,
    "orange": 1.00,
    "papaya": 1.00,
    "pigeonpeas": 1.00,
    "pomegranate": 1.00,
    "watermelon": 1.05
}

def calculate_irrigation(
    crop: str,
    et0: float,
    rainfall: float,
    area: float,
    irrigation_efficiency: float = 0.80
):
    crop = crop.lower().strip()

    if crop not in CROP_KC:
        raise ValueError(f"Crop '{crop}' is not supported.")

    if area <= 0:
        raise ValueError("Area must be greater than 0.")

    if not 0 < irrigation_efficiency <= 1:
        raise ValueError(
            "Irrigation efficiency must be between 0 and 1."
        )

    kc = CROP_KC[crop]

    # Crop evapotranspiration
    etc = et0 * kc

    # Assume 70% of rainfall is effectively available to the crop
    effective_rainfall = rainfall * 0.70

    # Net irrigation requirement
    net_irrigation = max(
        0,
        etc - effective_rainfall
    )

    # Gross irrigation requirement
    gross_irrigation = (
        net_irrigation / irrigation_efficiency
    )

    # 1 mm of water over 1 square meter = 1 liter
    water_liters = gross_irrigation * area

    if net_irrigation == 0:
        message = "No irrigation is required based on today's conditions."
    else:
        message = "Irrigation is recommended based on today's conditions."

    return {
        "crop": crop,
        "et0_mm_per_day": round(et0, 2),
        "kc": kc,
        "crop_water_requirement_mm": round(etc, 2),
        "rainfall_mm": round(rainfall, 2),
        "effective_rainfall_mm": round(effective_rainfall, 2),
        "net_irrigation_requirement_mm": round(
            net_irrigation, 2
        ),
        "gross_irrigation_requirement_mm": round(
            gross_irrigation, 2
        ),
        "area_m2": round(area, 2),
        "recommended_water_liters": round(
            water_liters, 2
        ),
        "message": message
    }

def get_irrigation_recommendation(
    latitude: float,
    longitude: float,
    crop: str,
    area: float,
    irrigation_efficiency: float = 0.80
):
    weather = get_weather(
        latitude=latitude,
        longitude=longitude
    )

    et0 = weather["forecast"]["reference_et0"][0]
    rainfall = weather["forecast"]["precipitation"][0]

    result = calculate_irrigation(
        crop=crop,
        et0=et0,
        rainfall=rainfall,
        area=area,
        irrigation_efficiency=irrigation_efficiency
    )

    result["location"] = {
        "latitude": latitude,
        "longitude": longitude
    }

    result["date"] = weather["forecast"]["dates"][0]

    return result

#gemini api prompt for chatbot
def ask_farming_assistant(message: str):
    prompt = f"""
You are a helpful agricultural assistant for farmers.

Your role is to provide:
- Simple and practical farming advice
- Crop management guidance
- Irrigation guidance
- Plant disease information
- Weather-related farming advice
- Soil and fertilizer guidance
- Sustainable farming practices

Important rules:
1. Give clear and easy-to-understand answers.
2. Avoid unnecessarily technical language.
3. Do not claim certainty when information is uncertain.
4. For serious plant disease or chemical treatment decisions,
   recommend consulting a local agricultural expert.
5. Focus on practical and environmentally responsible farming.

Farmer's question:
{message}
"""

    response = gemini_client.models.generate_content(
        model="gemini-3.8-flash",
        contents=prompt
    )

    return response.text

def ask_context_farming_assistant(
    message: str,
    crop: str,
    latitude: float,
    longitude: float,
    area: float
):
    # Get current weather and forecast
    weather = get_weather(
        latitude=latitude,
        longitude=longitude
    )

    # Get today's ET0 and rainfall
    et0 = weather["forecast"]["reference_et0"][0]
    rainfall = weather["forecast"]["precipitation"][0]
    date = weather["forecast"]["dates"][0]

    # Calculate irrigation requirement
    irrigation = calculate_irrigation(
        crop=crop,
        et0=et0,
        rainfall=rainfall,
        area=area,
        irrigation_efficiency=0.80
    )

    # Give Gemini the real backend data
    prompt = f"""
You are an AI farming assistant.

Answer the farmer's question using the real farm and
weather information provided below.

FARM INFORMATION:
Crop: {crop}
Field area: {area} square meters
Location: latitude {latitude}, longitude {longitude}

WEATHER INFORMATION:
Date: {date}
ET0: {et0} mm/day
Rainfall: {rainfall} mm

IRRIGATION INFORMATION:
Crop water requirement:
{irrigation["crop_water_requirement_mm"]} mm/day

Effective rainfall:
{irrigation["effective_rainfall_mm"]} mm

Net irrigation requirement:
{irrigation["net_irrigation_requirement_mm"]} mm

Gross irrigation requirement:
{irrigation["gross_irrigation_requirement_mm"]} mm

Recommended water:
{irrigation["recommended_water_liters"]} liters

The farmer asked:
{message}

Instructions:
1. Give practical and easy-to-understand farming advice.
2. Use the provided weather and irrigation values in your answer
   whenever relevant.
3. Do not invent weather or irrigation values.
4. Clearly distinguish calculated information from general advice.
5. Keep the answer reasonably concise.
6. For disease or pesticide decisions, recommend consulting
   a local agricultural expert when appropriate.
"""

    response = gemini_client.models.generate_content(
        model="gemini-3.8-flash",
        contents=prompt
    )

    return {
        "message": message,
        "crop": crop,
        "date": date,
        "weather": {
            "et0_mm_per_day": et0,
            "rainfall_mm": rainfall
        },
        "irrigation": irrigation,
        "response": response.text
    }


# Soil classification model
import json
from pathlib import Path

import numpy as np
from PIL import Image
from tensorflow import keras

BASE_DIR = Path(__file__).resolve().parents[1]
SOIL_MODEL_DIR = BASE_DIR / "models" / "soil_model"

soil_model = keras.models.load_model(
    SOIL_MODEL_DIR / "soil_model_final.keras"
)

with open(SOIL_MODEL_DIR / "class_names.json", "r") as file:
    soil_class_names = json.load(file)


def predict_soil(image: Image.Image):
    """Predict soil category from an uploaded soil image."""

    image = image.convert("RGB").resize((224, 224))
    image_array = np.array(image, dtype=np.float32)
    image_array = np.expand_dims(image_array, axis=0)

    # The training model contains its own pixel rescaling layer.
    predictions = soil_model.predict(image_array, verbose=0)

    predicted_index = int(np.argmax(predictions[0]))
    confidence = float(predictions[0][predicted_index])

    return {
        "soil_type": soil_class_names[predicted_index],
        "confidence": round(confidence * 100, 2),
        "message": (
            "Visual soil classification estimate. "
            "A soil test is needed to determine pH and nutrients."
        ),
    }