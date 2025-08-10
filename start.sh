#!/bin/bash

echo "[INFO] Pod run-diffusion-pipe started"

# Set up SSH if PUBLIC_KEY is provided
if [[ -n "$PUBLIC_KEY" ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    service ssh start
fi

# Move necessary files to workspace
for script in diffusion-pipe-on-workspace.sh readme-on-workspace.sh config_examples-on-workspace.sh provisioning-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "⚠️ Skipping $script (not found)"
    fi
done

# GPU detection
HAS_GPU=0
if [[ -n "${RUNPOD_GPU_COUNT:-}" && "${RUNPOD_GPU_COUNT:-0}" -gt 0 ]]; then
  HAS_GPU=1
elif command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi >/dev/null 2>&1 && HAS_GPU=1 || true
elif [[ -n "${CUDA_VISIBLE_DEVICES:-}" && "${CUDA_VISIBLE_DEVICES}" != "-1" ]]; then
  HAS_GPU=1
fi

# Run services
if [[ "$HAS_GPU" -eq 1 ]]; then
    # Start code-server (HTTP port 9000)
    if [[ -n "$PASSWORD" ]]; then
        code-server /workspace --auth password --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
		sleep 1
    else
        echo "⚠️ WARNING: PASSWORD is not set as an environment variable"
        code-server /workspace --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    fi
	
	# Start TensorBoard on port 6006
    tensorboard --logdir /workspace/output --host 0.0.0.0 &
	sleep 1
	
else
    echo "⚠️ WARNING: No GPU available, servers not started to limit memory use"
fi
	
# Login to Hugging Face if token is provided
if [[ -n "$HF_TOKEN" ]]; then
    hf auth login --token "$HF_TOKEN"
	sleep 1
else
	echo "⚠️ WARNING: HF_TOKEN is not set as an environment variable"
fi

# Function to download models if variables are set
download_model_HF2() {
    local model_var="$1"
    local file_var="$2"
    local dest_dir="$3"

    if [[ -n "${!model_var}" && -n "${!file_var}" ]]; then
        hf download "${!model_var}" "${!file_var}" --local-dir "/workspace/models/$dest_dir/"
		sleep 1
    else
        echo "⚠️ WARNING: No model or file specified for $dest_dir, skipping."
    fi
}

download_model_HF1() {
    local model_var="$1"
    local dest_dir="$2"

    if [[ -n "${!model_var}" ]]; then
        hf download "${!model_var}" --local-dir "/workspace/models/$dest_dir/"
		sleep 1
    else
        echo "⚠️ WARNING: No model specified for $dest_dir, skipping."
    fi
}

# Create workspace directories if they don’t exist
mkdir -p /workspace/models/vae \
         /workspace/models/llm \
         /workspace/models/clip \
         /workspace/models/transformer \
		 /workspace/models/ckpt_path \
		 /workspace/models/diffusers_path \	 
         /workspace/output

# Provisioning Models

echo "[INFO] Provisioning started"

download_model_HF2 HF_MODEL_VAE HF_MODEL_VAE_SAFETENSORS "vae"
download_model_HF2 HF_MODEL_TRANSFORMER HF_MODEL_TRANSFORMER_SAFETENSORS "transformer"
download_model_HF1 HF_MODEL_LLM "llm"
download_model_HF1 HF_MODEL_CLIP "clip"
download_model_HF1 HF_MODEL_CKPT "ckpt_path"
download_model_HF1 HF_MODEL_DIFFUSERS "diffusers_path"

# Final message
echo "✅ Provisioning done"

# Keep the container running
exec sleep infinity
