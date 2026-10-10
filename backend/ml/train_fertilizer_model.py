
from pathlib import Path
import json
import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.dummy import DummyClassifier

# Project paths
BASE_DIR = Path(__file__).resolve().parents[1]
DATA_PATH = BASE_DIR / "data" / "Fertilizer Prediction.csv"
MODEL_DIR = BASE_DIR / "models" / "fertilizer_model"
MODEL_DIR.mkdir(parents=True, exist_ok=True)

# Load dataset
df = pd.read_csv(DATA_PATH)

# Normalize column names (handles trailing spaces)
df.columns = df.columns.str.strip()

# Correct spelling and preserve feature meaning
df = df.rename(columns={
    "Temparature": "Temperature",
    "Humidity": "Humidity",
    "Phosphorous": "Phosphorus"
})

features = [
    "Temperature",
    "Humidity",
    "Moisture",
    "Soil Type",
    "Crop Type",
    "Nitrogen",
    "Potassium",
    "Phosphorus"
]
target = "Fertilizer Name"

X = df[features]
y = df[target].astype(str).str.strip()

# Use a stratified split so each fertilizer class is represented
# in both train and test sets.
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.25,
    random_state=42,
    stratify=y
)

numeric_features = [
    "Temperature", "Humidity", "Moisture",
    "Nitrogen", "Potassium", "Phosphorus"
]
categorical_features = ["Soil Type", "Crop Type"]

preprocessor = ColumnTransformer([
    ("numeric", StandardScaler(), numeric_features),
    ("categorical", OneHotEncoder(handle_unknown="ignore"),
     categorical_features)
])

model = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", RandomForestClassifier(
        n_estimators=200,
        class_weight="balanced",
        random_state=42
    ))
])

# Train and evaluate
model.fit(X_train, y_train)
predictions = model.predict(X_test)

accuracy = accuracy_score(y_test, predictions)

# Baseline: always predict the most frequent training class
baseline = DummyClassifier(strategy="most_frequent")
baseline.fit(X_train, y_train)
baseline_predictions = baseline.predict(X_test)
baseline_accuracy = accuracy_score(y_test, baseline_predictions)

print(f"Dataset rows: {len(df)}")
print(f"Training rows: {len(X_train)}")
print(f"Testing rows: {len(X_test)}")
print(f"Fertilizer classes: {sorted(y.unique())}")
print(f"Random Forest accuracy: {accuracy:.2%}")
print(f"Baseline accuracy: {baseline_accuracy:.2%}")
print("\nClassification report:")
print(classification_report(
    y_test, predictions, zero_division=0
))

# Save model and metadata
joblib.dump(model, MODEL_DIR / "fertilizer_model.joblib")

metadata = {
    "features": features,
    "target": target,
    "classes": sorted(y.unique()),
    "dataset_rows": len(df),
    "test_accuracy": round(float(accuracy), 4),
    "baseline_accuracy": round(float(baseline_accuracy), 4)
}

with open(MODEL_DIR / "metadata.json", "w", encoding="utf-8") as f:
    json.dump(metadata, f, indent=2)

print(f"\nModel saved to: {MODEL_DIR}")