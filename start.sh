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
for script in diffusion-pipe-on-workspace.sh readme-on-workspace.sh examples-on-workspace.sh provisioning-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "Skipping $script (not found)"
    fi
done

# Start Servers
if [[ ${RUNPOD_GPU_COUNT:-0} -gt 0 ]]; then
    # Start code-server (HTTP port 9000)
    if [[ -n "$PASSWORD" ]]; then
        code-server /workspace --auth password --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
        echo "WARNING: PASSWORD is not set as an environment variable"
        code-server /workspace --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    fi
	
	# Start TensorBoard on port 6006
    tensorboard --logdir /workspace/output --host 0.0.0.0 &
	
else
    echo "WARNING: No GPU available, servers not started to limit memory use"
fi
	
# Login to Hugging Face if token is provided
if [[ -n "$HF_TOKEN" ]]; then
    huggingface-cli login --token "$HF_TOKEN"
else
	echo "WARNING: HF_TOKEN is not set as an environment variable"
fi

# Create workspace directories if they don’t exist
mkdir -p /workspace/models/vae \
         /workspace/models/llm \
         /workspace/models/clip \
         /workspace/models/transformer \
		 /workspace/models/ckpt_path \
         /workspace/output

# Download Hugging Face models if specified
[[ -n "$HF_MODEL_VAE" && -n "$HF_MODEL_VAE_SAFETENSORS" ]] && \
    huggingface-cli download "$HF_MODEL_VAE" "$HF_MODEL_VAE_SAFETENSORS" \
    --local-dir /workspace/models/vae/

[[ -n "$HF_MODEL_LLM" ]] && \
    huggingface-cli download "$HF_MODEL_LLM" \
    --local-dir /workspace/models/llm/

[[ -n "$HF_MODEL_CLIP" ]] && \
    huggingface-cli download "$HF_MODEL_CLIP" \
    --local-dir /workspace/models/clip/

[[ -n "$HF_MODEL_TRANSFORMER" && -n "$HF_MODEL_TRANSFORMER_SAFETENSORS" ]] && \
    huggingface-cli download "$HF_MODEL_TRANSFORMER" "$HF_MODEL_TRANSFORMER_SAFETENSORS" \
    --local-dir /workspace/models/transformer/

[[ -n "$HF_MODEL_CKPT" ]] && \
    huggingface-cli download "$HF_MODEL_CKPT" \
    --local-dir /workspace/models/ckpt_path/

# Final message
echo "[INFO] Provisioning done"

# Keep the container running
exec sleep infinity
