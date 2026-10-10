from pathlib import Path
import json
import numpy as np
import tensorflow as tf

from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix


# ============================================================
# PATHS
# ============================================================

PROJECT_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = PROJECT_DIR / "data" / "plantvillage" / "raw" / "color"

MODEL_DIR = PROJECT_DIR / "data" / "disease_model"
MODEL_DIR.mkdir(parents=True, exist_ok=True)

# ============================================================
# SETTINGS
# ============================================================

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 5
SEED = 42


# ============================================================
# 9 CLASSES FOR MVP
# ============================================================

SELECTED_CLASSES = [
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight",
    "Corn_(maize)___healthy",

    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",

    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___healthy",
]


# ============================================================
# CHECK DATASET
# ============================================================

if not DATA_DIR.exists():
    raise FileNotFoundError(
        f"\nDataset not found:\n{DATA_DIR}\n"
    )

print("\nDataset location:")
print(DATA_DIR)


# ============================================================
# COLLECT IMAGE PATHS
# ============================================================

image_paths = []
labels = []

print("\nCollecting images...\n")

for class_index, class_name in enumerate(SELECTED_CLASSES):

    class_dir = DATA_DIR / class_name

    if not class_dir.exists():
        raise FileNotFoundError(
            f"\nRequired class folder not found:\n{class_dir}"
        )

    files = list(class_dir.glob("*.jpg"))

    print(f"{class_name}: {len(files)} images")

    for file in files:
        image_paths.append(str(file))
        labels.append(class_index)


image_paths = np.array(image_paths)
labels = np.array(labels)

print("\n========================================")
print("Dataset Summary")
print("========================================")
print(f"Total images: {len(image_paths)}")
print(f"Total classes: {len(SELECTED_CLASSES)}")


# ============================================================
# TRAIN / VALIDATION SPLIT
# ============================================================

train_paths, val_paths, train_labels, val_labels = train_test_split(
    image_paths,
    labels,
    test_size=0.20,
    random_state=SEED,
    stratify=labels
)

print(f"Training images: {len(train_paths)}")
print(f"Validation images: {len(val_paths)}")


# ============================================================
# IMAGE LOADING FUNCTION
# ============================================================

def load_image(path, label):

    image = tf.io.read_file(path)

    image = tf.image.decode_jpeg(
        image,
        channels=3
    )

    image = tf.image.resize(
        image,
        IMAGE_SIZE
    )

    image = tf.cast(
        image,
        tf.float32
    )

    return image, label


# ============================================================
# CREATE TF.DATA DATASETS
# ============================================================

train_dataset = tf.data.Dataset.from_tensor_slices(
    (train_paths, train_labels)
)

validation_dataset = tf.data.Dataset.from_tensor_slices(
    (val_paths, val_labels)
)

train_dataset = train_dataset.map(
    load_image,
    num_parallel_calls=tf.data.AUTOTUNE
)

validation_dataset = validation_dataset.map(
    load_image,
    num_parallel_calls=tf.data.AUTOTUNE
)


# ============================================================
# DATA AUGMENTATION
# ============================================================

data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
])


# ============================================================
# MOBILE NET V2
# ============================================================

base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)

# Freeze pretrained layers
base_model.trainable = False


# ============================================================
# BUILD MODEL
# ============================================================

model = models.Sequential([

    layers.Input(
        shape=(224, 224, 3)
    ),

    data_augmentation,

    # Convert [0,255] → [-1,1]
    layers.Rescaling(
        1.0 / 127.5,
        offset=-1
    ),

    base_model,

    layers.GlobalAveragePooling2D(),

    layers.Dropout(0.2),

    layers.Dense(
        len(SELECTED_CLASSES),
        activation="softmax"
    )
])


# ============================================================
# COMPILE
# ============================================================

model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)


print("\n========================================")
print("MobileNetV2 Model")
print("========================================")

model.summary()


# ============================================================
# PREPARE DATA
# ============================================================

AUTOTUNE = tf.data.AUTOTUNE

train_dataset = (
    train_dataset
    .shuffle(1000, seed=SEED)
    .batch(BATCH_SIZE)
    .prefetch(AUTOTUNE)
)

validation_dataset = (
    validation_dataset
    .batch(BATCH_SIZE)
    .prefetch(AUTOTUNE)
)


# ============================================================
# CALLBACKS
# ============================================================

model_path = MODEL_DIR / "disease_model.keras"

callbacks = [

    EarlyStopping(
        monitor="val_loss",
        patience=2,
        restore_best_weights=True
    ),

    ModelCheckpoint(
        filepath=model_path,
        monitor="val_accuracy",
        save_best_only=True
    )
]


# ============================================================
# TRAIN MODEL
# ============================================================

print("\n========================================")
print("Starting Disease Model Training")
print("========================================\n")

history = model.fit(
    train_dataset,
    validation_data=validation_dataset,
    epochs=EPOCHS,
    callbacks=callbacks
)


# ============================================================
# SAVE FINAL MODEL
# ============================================================

final_model_path = MODEL_DIR / "disease_model_final.keras"

model.save(final_model_path)


# ============================================================
# SAVE CLASS NAMES
# ============================================================

class_names_path = MODEL_DIR / "class_names.json"

with open(
    class_names_path,
    "w",
    encoding="utf-8"
) as file:

    json.dump(
        SELECTED_CLASSES,
        file,
        indent=4
    )


# ============================================================
# EVALUATE MODEL
# ============================================================

print("\n========================================")
print("Evaluating Model")
print("========================================")

loss, accuracy = model.evaluate(
    validation_dataset,
    verbose=1
)

print(f"\nValidation Accuracy: {accuracy * 100:.2f}%")


# ============================================================
# GENERATE PREDICTIONS
# ============================================================

y_true = []
y_pred = []


for images, labels_batch in validation_dataset:

    predictions = model.predict(
        images,
        verbose=0
    )

    predicted_classes = np.argmax(
        predictions,
        axis=1
    )

    y_true.extend(
        labels_batch.numpy()
    )

    y_pred.extend(
        predicted_classes
    )


# ============================================================
# CLASSIFICATION REPORT
# ============================================================

print("\n========================================")
print("Classification Report")
print("========================================\n")

report = classification_report(
    y_true,
    y_pred,
    target_names=SELECTED_CLASSES,
    digits=4
)

print(report)


# ============================================================
# CONFUSION MATRIX
# ============================================================

print("\n========================================")
print("Confusion Matrix")
print("========================================\n")

matrix = confusion_matrix(
    y_true,
    y_pred
)

print(matrix)


# ============================================================
# SAVE METRICS
# ============================================================

metrics = {
    "validation_accuracy": float(accuracy),
    "classes": SELECTED_CLASSES,
    "training_images": len(train_paths),
    "validation_images": len(val_paths),
    "image_size": IMAGE_SIZE,
    "batch_size": BATCH_SIZE,
    "epochs": EPOCHS
}

with open(
    MODEL_DIR / "metrics.json",
    "w",
    encoding="utf-8"
) as file:

    json.dump(
        metrics,
        file,
        indent=4
    )


# ============================================================
# COMPLETE
# ============================================================

print("\n========================================")
print("TRAINING COMPLETED")
print("========================================")

print(f"Model:")
print(final_model_path)

print(f"\nClass names:")
print(class_names_path)

print("\nDisease model is ready for FastAPI.")