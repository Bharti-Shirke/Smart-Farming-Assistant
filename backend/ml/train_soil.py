
import json
from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Project paths
BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data" / "soil dataset"
TRAIN_DIR = DATA_DIR / "Train"
TEST_DIR = DATA_DIR / "test"

MODEL_DIR = BASE_DIR / "models" / "soil_model"
MODEL_DIR.mkdir(parents=True, exist_ok=True)

IMG_SIZE = (224, 224)
BATCH_SIZE = 16
SEED = 42
EPOCHS = 20

print("TensorFlow version:", tf.__version__)
print("Training folder:", TRAIN_DIR)
print("Testing folder:", TEST_DIR)

# Load training data and reserve 20% for validation
train_ds = keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    validation_split=0.2,
    subset="training",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="int",
)

val_ds = keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    validation_split=0.2,
    subset="validation",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="int",
)

# Load the independent test set
test_ds = keras.utils.image_dataset_from_directory(
    TEST_DIR,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=False,
    label_mode="int",
)

class_names = train_ds.class_names
print("\nSoil classes:", class_names)
print("Number of classes:", len(class_names))

if class_names != test_ds.class_names:
    raise ValueError(
        "Training and testing class folders do not match!"
    )

# Improve input pipeline performance
AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.prefetch(AUTOTUNE)
val_ds = val_ds.prefetch(AUTOTUNE)
test_ds = test_ds.prefetch(AUTOTUNE)

# Data augmentation for better generalization
augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.08),
    layers.RandomZoom(0.10),
])

# Transfer learning using MobileNetV2
base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)
base_model.trainable = False

inputs = keras.Input(shape=(224, 224, 3))
x = augmentation(inputs)

# MobileNetV2 expects pixel values scaled to [-1, 1]
x = layers.Rescaling(1.0 / 127.5, offset=-1)(x)

x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.3)(x)
outputs = layers.Dense(
    len(class_names),
    activation="softmax"
)(x)

model = keras.Model(inputs, outputs)

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()

# Save the best model based on validation accuracy
checkpoint_path = MODEL_DIR / "best_soil.keras"

callbacks = [
    keras.callbacks.ModelCheckpoint(
        str(checkpoint_path),
        monitor="val_accuracy",
        save_best_only=True,
        mode="max",
        verbose=1,
    ),
    keras.callbacks.EarlyStopping(
        monitor="val_loss",
        patience=5,
        restore_best_weights=True,
        verbose=1,
    ),
]

# Train
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=callbacks,
)

# Evaluate on the independent test set
test_loss, test_accuracy = model.evaluate(test_ds, verbose=1)

print(f"\nTest loss: {test_loss:.4f}")
print(f"Test accuracy: {test_accuracy * 100:.2f}%")

# Save the trained model
final_model_path = MODEL_DIR / "soil_model_final.keras"
model.save(final_model_path)

# Save class names in the same order used by the model
with open(MODEL_DIR / "class_names.json", "w") as f:
    json.dump(class_names, f, indent=4)

# Save basic evaluation results
results = {
    "classes": class_names,
    "test_loss": float(test_loss),
    "test_accuracy": float(test_accuracy),
    "training_images": len(train_ds) * BATCH_SIZE,
    "test_images": len(test_ds) * BATCH_SIZE,
}

with open(MODEL_DIR / "evaluation.json", "w") as f:
    json.dump(results, f, indent=4)

print("\nTraining completed!")
print("Model saved at:", final_model_path)
print("Class names saved at:", MODEL_DIR / "class_names.json")