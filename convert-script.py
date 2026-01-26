import torch
import torchvision.models as models
import torch.nn as nn
import coremltools as ct

# 1. Cargar modelo base pre-entrenado (ResNet o MobileNet)
print("Cargando modelo base...")
# Opción 1: ResNet50 (más preciso)
# model = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V2)

# Opción 2: MobileNetV2 (más rápido para iPhone)
model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.IMAGENET1K_V2)

# 2. Modificar la última capa para 102 clases de flores
model.classifier[1] = nn.Linear(model.classifier[1].in_features, 102)

model.eval()
print("✅ Modelo cargado")

# 3. Crear input de ejemplo
example_input = torch.rand(1, 3, 224, 224)

# 4. Trazar el modelo
print("Trazando modelo...")
traced_model = torch.jit.trace(model, example_input)

# 5. Leer las etiquetas de flores
print("Cargando etiquetas...")
with open('flower-labels.txt', 'r', encoding='utf-8') as f:
    class_labels = [line.strip() for line in f.readlines()]

print(f"Total de clases: {len(class_labels)}")

# 6. Convertir a Core ML
print("Convirtiendo a Core ML...")
coreml_model = ct.convert(
    traced_model,
    inputs=[ct.ImageType(
        name="data",
        shape=example_input.shape,
        scale=1/255.0,
        bias=[0, 0, 0]
    )],
    classifier_config=ct.ClassifierConfig(class_labels),
    convert_to="neuralnetwork"
)

# 7. Agregar metadata
coreml_model.author = "Clasificador de Flores"
coreml_model.short_description = "Clasificador de 102 especies de flores usando MobileNetV2"
coreml_model.version = "2.0"

# 8. Guardar
output_file = "flower-classifier.mlmodel"
coreml_model.save(output_file)
print(f"✅ Modelo guardado en '{output_file}'")
print("\nAhora puedes arrastrarlo a Xcode para usarlo en tu app Swift!")