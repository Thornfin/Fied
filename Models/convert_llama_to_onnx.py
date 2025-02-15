import torch
from transformers import LlamaForCausalLM, LlamaTokenizer

# Specify the path to your downloaded model
model_path = "/Users/ilyassserghini/.llama/checkpoints/Llama3.2-1B-Instruct"

# Load the model and tokenizer
model = LlamaForCausalLM.from_pretrained(model_path)
tokenizer = LlamaTokenizer.from_pretrained(model_path)

# Prepare a dummy input for exporting the model to ONNX format
dummy_input = tokenizer("Convert this model to ONNX.", return_tensors="pt").input_ids

# Export the model to ONNX format
torch.onnx.export(
    model,
    dummy_input,
    "llama_model.onnx",
    input_names=["input_ids"],
    output_names=["output"],
    opset_version=11
)

print("Model exported successfully to llama_model.onnx")
