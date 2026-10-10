from pathlib import Path
import json
import pickle

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix


# --------------------------------------------------
# PATHS
# --------------------------------------------------

# train_crop.py is inside:
# backend/ml/train_crop.py
#
# parent.parent gives:
# backend/

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_PATH = BASE_DIR / "data" / "Crop_recommendation.csv"
MODEL_DIR = BASE_DIR / "models" / "crop_model"

MODEL_DIR.mkdir(parents=True, exist_ok=True)

MODEL_PATH = MODEL_DIR / "crop_model.pkl"
FEATURE_PATH = MODEL_DIR / "feature_names.json"


# --------------------------------------------------
# LOAD DATASET
# --------------------------------------------------

print("Loading dataset...")
print(f"Dataset path: {DATA_PATH}")

df = pd.read_csv(DATA_PATH)

print("\nDataset shape:", df.shape)
print("\nColumns:")
print(df.columns.tolist())

print("\nFirst 5 rows:")
print(df.head())


# --------------------------------------------------
# CLEAN COLUMN NAMES
# --------------------------------------------------

df.columns = df.columns.str.strip().str.lower()

print("\nCleaned columns:")
print(df.columns.tolist())


# --------------------------------------------------
# FEATURES AND TARGET
# --------------------------------------------------

feature_names = [
    "n",
    "p",
    "k",
    "temperature",
    "humidity",
    "ph",
    "rainfall"
]

target_column = "label"


# Check required columns
required_columns = feature_names + [target_column]

missing_columns = [
    column for column in required_columns
    if column not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Missing columns in dataset: {missing_columns}"
    )


X = df[feature_names]
y = df[target_column]


# --------------------------------------------------
# CHECK DATA
# --------------------------------------------------

print("\nNumber of samples:", len(df))
print("Number of features:", len(feature_names))
print("Number of crops:", y.nunique())

print("\nCrop classes:")
print(sorted(y.unique()))


# --------------------------------------------------
# TRAIN / TEST SPLIT
# --------------------------------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

print("\nTraining samples:", len(X_train))
print("Testing samples:", len(X_test))


# --------------------------------------------------
# RANDOM FOREST MODEL
# --------------------------------------------------

print("\nTraining Random Forest...")

model = RandomForestClassifier(
    n_estimators=200,
    random_state=42,
    n_jobs=-1
)

model.fit(X_train, y_train)

print("Training completed.")


# --------------------------------------------------
# EVALUATION
# --------------------------------------------------

y_pred = model.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)

print("\n----------------------------------------")
print("MODEL PERFORMANCE")
print("----------------------------------------")

print(f"Accuracy: {accuracy * 100:.2f}%")

print("\nClassification Report:")
print(classification_report(y_test, y_pred))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))


# --------------------------------------------------
# SAVE MODEL
# --------------------------------------------------

with open(MODEL_PATH, "wb") as file:
    pickle.dump(model, file)

print("\nModel saved to:")
print(MODEL_PATH)


# --------------------------------------------------
# SAVE FEATURE NAMES
# --------------------------------------------------

with open(FEATURE_PATH, "w", encoding="utf-8") as file:
    json.dump(feature_names, file, indent=4)

print("\nFeature names saved to:")
print(FEATURE_PATH)


# --------------------------------------------------
# TEST SAMPLE
# --------------------------------------------------

sample = pd.DataFrame(
    [[
        90,
        42,
        43,
        20.8,
        82.0,
        6.5,
        202.9
    ]],
    columns=feature_names
)

sample_prediction = model.predict(sample)[0]

sample_probabilities = model.predict_proba(sample)[0]
sample_confidence = max(sample_probabilities)

print("\n----------------------------------------")
print("SAMPLE PREDICTION")
print("----------------------------------------")

print("Input:")
print(sample)

print("\nRecommended crop:", sample_prediction)
print("Confidence:", f"{sample_confidence * 100:.2f}%")

print("\nCrop model training complete!")