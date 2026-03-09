#!/bin/bash

echo "ℹ️ Pod run-diffusion-pipe started"
echo "ℹ️ Wait until the message 🎉 Provisioning done, ready to train AI content 🎉. is displayed"

# Enable SSH if PUBLIC_KEY is set
if [[ -n "$PUBLIC_KEY" ]]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    service ssh start
    echo "✅ [SSH enabled]"
fi

# Export env variables
if [[ -n "${RUNPOD_GPU_COUNT:-}" ]]; then
   echo "ℹ️ Exporting runpod.io environment variables..."
   printenv | grep -E '^RUNPOD_|^PATH=|^_=' \
     | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment

   echo 'source /etc/rp_environment' >> ~/.bashrc
fi

# Move necessary files to workspace
echo "ℹ️ [Moving necessary files to workspace] enabling rebooting pod without data loss"
for script in diffusion-pipe-on-workspace.sh readme-on-workspace.sh docs-on-workspace.sh; do
    if [ -f "/$script" ]; then
        echo "Executing $script..."
        "/$script"
    else
        echo "⚠️ Skipping $script (not found)"
    fi
done

# GPU detection
echo "ℹ️ Testing GPU/CUDA provisioning"

# GPU detection Runpod.io
HAS_GPU_RUNPOD=0
if [[ -n "${RUNPOD_GPU_COUNT:-}" && "${RUNPOD_GPU_COUNT:-0}" -gt 0 ]]; then
  HAS_GPU_RUNPOD=1
  echo "✅ [GPU DETECTED] Found via RUNPOD_GPU_COUNT=${RUNPOD_GPU_COUNT}"
else
  echo "⚠️ [NO GPU] No Runpod.io GPU detected."
fi  

# GPU detection nvidia-smi
HAS_GPU=0
if command -v nvidia-smi >/dev/null 2>&1; then
  if nvidia-smi >/dev/null 2>&1; then
    HAS_GPU=1
    GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader | xargs | sed 's/,/, /g')
    echo "✅ [GPU DETECTED] Found via nvidia-smi → Model(s): ${GPU_MODEL}"
  else
    echo "⚠️ [NO GPU] nvidia-smi found but failed to run (driver or permission issue)"
  fi
else
  echo "⚠️ [NO GPU] No GPU found via nvidia-smi"
fi

# Start code-server (HTTP port 9000) 
if [[ "$HAS_GPU" -eq 1 || "$HAS_GPU_RUNPOD" -eq 1 ]]; then    
    echo "✅ Code-Server service starting"
	
    if [[ -n "$PASSWORD" ]]; then
        code-server /workspace --auth password --disable-update-check --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
        echo "⚠️ PASSWORD is not set as an environment variable use password from /root/.config/code-server/config.yaml"
        code-server /workspace --disable-telemetry --disable-update-check --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    fi
	
    echo "🎉 code-server service started"
else
    echo "⚠️ WARNING: No GPU available, Code Server not started to limit memory use"
fi

sleep 2

# Python, Torch CUDA check
HAS_CUDA=0
if command -v python >/dev/null 2>&1; then
  if python - << 'PY' >/dev/null 2>&1
import sys
try:
    import torch
    sys.exit(0 if torch.cuda.is_available() else 1)
except Exception:
    sys.exit(1)
PY
  then
    HAS_CUDA=1
  fi
else
  echo "⚠️ Python not found – assuming no CUDA"
fi

if [[ "$HAS_CUDA" -eq 1 ]]; then  	
    echo "✅ Starting Tensorboard service (CUDA available)"

	# Start TensorBoard on port 6006
    tensorboard --logdir /workspace/output --host 0.0.0.0 &
	sleep 1
	
else
    echo "❌ ERROR: PyTorch CUDA driver mismatch or unavailable, tensorboard not started"
fi
	
# Create workspace directories if they don’t exist
mkdir -p /workspace/output

download_HF() {
    local model_var="$1"
    local file_var="$2"
    local dest_dir="$3"

    local model="${!model_var}"
    [[ -z "$model" ]] && return 0

    local file=""
    if [[ -n "$file_var" ]]; then
        file="${!file_var}"
    fi

    local target="/workspace/models/$dest_dir"
    mkdir -p "$target"

    if [[ -n "$file" ]]; then
        echo "ℹ️ [DOWNLOAD] Fetching $model/$file → $target"
        hf download "$model" "$file" --local-dir "$target" || \
            echo "⚠️ Failed to download $model/$file"
    else
        echo "ℹ️ [DOWNLOAD] Fetching $model → $target"
        hf download "$model" --local-dir "$target" || \
            echo "⚠️ Failed to download $model"
    fi

    sleep 1
    return 0
}

# Provisioning if running on GPU with CUDA
if [[ "$HAS_CUDA" -eq 1 ]]; then  
   echo "📥 Provisioning models"
   
   # Huggingface download file to specified directory
    for i in $(seq 1 20); do
        VAR1="HF_MODEL${i}"
        VAR2="HF_MODEL_FILENAME${i}"
        DIR_VAR="HF_MODEL_DIR${i}"
        download_HF "${VAR1}" "${VAR2}" "${!DIR_VAR}"
    done
	
    # Huggingface download full model to specified directory
    for i in $(seq 1 20); do
        VAR1="HF_FULL_MODEL${i}"
        DIR_VAR="HF_MODEL_DIR${i}"
        download_HF "${VAR1}" "" "${!DIR_VAR}"
    done  

   HAS_PROVISIONING=1
else
   HAS_PROVISIONING=0   
   echo "⚠️ Skipped Provisioning: No models downloaded as no gpu cuda"
fi

# Environment
echo "ℹ️ Running environment"

python - <<'PY'
import platform

# Safe imports – don't explode if something is missing
try:
    import torch
except Exception as e:
    print(f"PyTorch import error: {e}")
    torch = None

try:
    import triton
except Exception:
    triton = None

try:
    import onnxruntime as ort
except Exception:
    ort = None

print(f"Python: {platform.python_version()}")

if torch is not None:
    print(f"PyTorch: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"  ↳ CUDA runtime: {torch.version.cuda}")
        print(f"  ↳ GPU(s): {[torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())]}")
        try:
            import torch.backends.cudnn as cudnn
            print(f"  ↳ cuDNN: {cudnn.version()}")
        except Exception:
            pass
    print("Torch build info:")
    try:
        torch.__config__.show()
    except Exception:
        pass
else:
    print("PyTorch: not available")
PY

if [[ "$HAS_PROVISIONING" -eq 1 ]]; then 
    echo "🎉 Provisioning done, ready to train AI content 🎉"
    
    if [[ "$HAS_GPU_RUNPOD" -eq 1 ]]; then
        echo "ℹ️ Connect to the following services from console menu or url"
	
	  if [[ -z "${RUNPOD_POD_ID:-}" ]]; then
	    echo "⚠️ RUNPOD_POD_ID not set — service URLs unavailable"
	  else
	    declare -A SERVICES=(
	      ["Code-Server"]=9000
		  ["Tensorboard"]=6006
	    )
	
	    # Local health checks (inside the pod)
	    for service in "${!SERVICES[@]}"; do
	      port="${SERVICES[$service]}"
	      url="https://${RUNPOD_POD_ID}-${port}.proxy.runpod.net/"
	      local_url="http://127.0.0.1:${port}/"
	
	      echo "👉 🔗 Service ${service} : ${url}"
	
	      # Check service locally (no proxy dependency)
	      http_code="$(curl -sS -o /dev/null -m 2 --connect-timeout 1 -w "%{http_code}" "$local_url" || true)"
	
	      # Treat common “service is up but protected/redirect” codes as UP
	      if [[ "$http_code" =~ ^(200|301|302|401|403|404)$ ]]; then
	        echo "✅ ${service} is running (local ${local_url}, HTTP ${http_code})"
	      else
	        echo "❌ ${service} not responding yet (local ${local_url}, HTTP ${http_code})"
	      fi
	    done
	  fi
    fi
else
    echo "ℹ️ Running error diagnosis"

    if [[ "$HAS_GPU_RUNPOD" -eq 0 ]]; then
        echo "⚠️ Pod started without a runpod GPU"
    fi

    if [[ "$HAS_CUDA" -eq 0 ]]; then
        echo "❌ Pytorch CUDA driver error/mismatch/not available"
        if [[ "$HAS_GPU_RUNPOD" -eq 1 ]]; then
            echo "⚠️ [SOLUTION] Deploy pod on another region then $RUNPOD_DC_ID ⚠️"
        fi
    fi
    
	echo "❌ Provisioning failed"
fi

# Keep the container running
echo "ℹ️ End script"

# Keep the container running
exec sleep infinity
