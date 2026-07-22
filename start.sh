#!/bin/bash

echo "ℹ️ Pod run-diffusion-pipe started"
echo "ℹ️ Wait until the message 🎉 Provisioning done, ready to train AI content 🎉. is displayed"

# Hugging Face CLI output tuned for RunPod plain logs.
export NO_COLOR=1
export HF_HUB_VERBOSITY=warning
export HF_HUB_DISABLE_TELEMETRY=1
export DO_NOT_TRACK=1

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
mkdir -p /workspace/models

# Provisioning routines (with watchdog)

run_hf_download() {
    local stall_timeout="${HF_DOWNLOAD_STALL_TIMEOUT:-300}"
    local kill_after="${HF_DOWNLOAD_KILL_AFTER:-30}"
    local hf_command
    local tmp_dir
    local fifo
    local pid
    local watchdog_pid
    local last_activity_file
    local exit_code
    local fallback=0

    echo "ℹ️ [DOWNLOAD] Stall watchdog: ${stall_timeout}s"
    echo "ℹ️ [DOWNLOAD] Kill grace period: ${kill_after}s"

    # Safely quote all arguments passed to: hf download
    printf -v hf_command '%q ' hf download "$@"

    tmp_dir="$(mktemp -d)"
    fifo="${tmp_dir}/hf-output.fifo"
    last_activity_file="${tmp_dir}/last_activity"

    mkfifo "$fifo"
    date +%s > "$last_activity_file"

    cleanup() {
        [[ -n "${watchdog_pid:-}" ]] && kill "$watchdog_pid" 2>/dev/null || true
        [[ -n "${pid:-}" ]] && kill "$pid" 2>/dev/null || true
        rm -rf "$tmp_dir"
    }

    trap cleanup RETURN

    run_download_attempt() {
        local disable_xet="$1"
        local backend_name="$2"

        date +%s > "$last_activity_file"

        echo "ℹ️ [DOWNLOAD] Starting with ${backend_name}..."

        (
            script --quiet --return --flush \
                --command "HF_HUB_DISABLE_XET=${disable_xet} ${hf_command}" \
                /dev/null
        ) >"$fifo" 2>&1 &

        pid=$!

        #
        # Watchdog:
        # Check every 10 seconds whether output has been received recently.
        #
        (
            while kill -0 "$pid" 2>/dev/null; do
                sleep 10

                local now
                local last
                local inactive

                now="$(date +%s)"
                last="$(cat "$last_activity_file" 2>/dev/null || echo "$now")"
                inactive=$((now - last))

                if (( inactive >= stall_timeout )); then
                    echo
                    echo "⚠️ [DOWNLOAD] No activity for ${inactive}s."
                    echo "⚠️ [DOWNLOAD] ${backend_name} appears stalled."

                    kill -TERM "$pid" 2>/dev/null || true

                    sleep "$kill_after"

                    if kill -0 "$pid" 2>/dev/null; then
                        echo "⚠️ [DOWNLOAD] Process did not stop after ${kill_after}s; sending SIGKILL."
                        kill -KILL "$pid" 2>/dev/null || true
                    fi

                    exit 124
                fi
            done
        ) &

        watchdog_pid=$!

        #
        # Read download output.
        # Every received line resets the inactivity watchdog.
        #
        while IFS= read -r line; do
            date +%s > "$last_activity_file"

            printf '%s\n' "$line"
        done < <(
            stdbuf -oL tr '\r' '\n' <"$fifo" \
                | sed -u -E \
                    -e '/^[[:space:]]*$/d' \
                    -e $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' \
                    -e 's/^([^:]+):[[:space:]]*([0-9]+)%\|[^|]*\|[[:space:]]*([^[:space:]]+).*/Downloading \1 \2% \3/'
        )

        wait "$pid"
        exit_code=$?

        kill "$watchdog_pid" 2>/dev/null || true
        wait "$watchdog_pid" 2>/dev/null || true

        pid=""
        watchdog_pid=""

        return "$exit_code"
    }

    #
    # Attempt 1: Xet
    #
    if run_download_attempt 0 "Xet"; then
        echo "✅ [DOWNLOAD] Download completed successfully with Xet."
        return 0
    fi

    exit_code=$?

    echo "⚠️ [DOWNLOAD] Xet download stopped or failed with exit code ${exit_code}."
    echo "ℹ️ [DOWNLOAD] Retrying with Xet disabled (plain HTTP)..."

    #
    # Attempt 2: plain HTTP
    #
    if run_download_attempt 1 "plain HTTP"; then
        echo "✅ [DOWNLOAD] Download completed successfully using plain HTTP."
        return 0
    fi

    exit_code=$?

    echo "❌ [DOWNLOAD] Plain HTTP download failed with exit code ${exit_code}."
    return "$exit_code"
}

download_HF() {
    local model_var="$1"
    local file_var="$2"
    local dest_dir="$3"
    local exclude_var="$4"
    local include_var="$5"

    local model="${!model_var}"
    [[ -z "$model" ]] && return 0

    if [[ -z "$dest_dir" ]]; then
        echo "⚠️ [$model_var] Skipping download: target directory is empty"
        return 0
    fi

    local file=""
    [[ -n "$file_var" ]] && file="${!file_var}"

    local exclude=""
    [[ -n "$exclude_var" ]] && exclude="${!exclude_var}"

    local include=""
    [[ -n "$include_var" ]] && include="${!include_var}"

    local target="/workspace/models/$dest_dir"
    mkdir -p "$target"

    local cmd=(hf download "$model" --local-dir "$target")

    [[ -n "$file" ]] && cmd+=("$file")

    if [[ -n "$include" ]]; then
        read -ra INCLUDES <<< "$include"
        cmd+=(--include "${INCLUDES[@]}")
    fi

    if [[ -n "$exclude" ]]; then
        read -ra EXCLUDES <<< "$exclude"
        cmd+=(--exclude "${EXCLUDES[@]}")
    fi

    echo "ℹ️ [DOWNLOAD] ${cmd[*]}"
    run_hf_download "${cmd[@]:2}" || echo "⚠️ Failed to download $model"

    sleep 1
}

# Provisioning if running on GPU with CUDA
if [[ "$HAS_CUDA" -eq 1 ]]; then  
   echo "📥 Provisioning models"
   
   hf update && hf version
   
   # Huggingface download file to specified local directory
    for i in $(seq 1 20); do
        VAR1="HF_MODEL${i}"
        VAR2="HF_MODEL_NAME${i}"
        DIR_VAR="HF_MODEL_LOCAL_DIR${i}"
        MODEL="${!VAR1}"
        FILE="${!VAR2}"
        DEST_DIR="${!DIR_VAR}"

        if [[ -z "$MODEL" ]]; then
            if [[ -n "$FILE" || -n "$DEST_DIR" ]]; then
                echo "⚠️ [HF_MODEL${i}] Skipping partial download: ${VAR1} is not set"
            fi
            continue
        fi

        if [[ -z "$DEST_DIR" ]]; then
            echo "⚠️ [HF_MODEL${i}] Skipping partial download: ${DIR_VAR} is not set"
            continue
        fi

        if [[ -z "$FILE" ]]; then
            echo "⚠️ [HF_MODEL${i}] ${VAR2} is not set, downloading full repository from ${VAR1}"
        fi

        download_HF "${VAR1}" "${VAR2}" "$DEST_DIR"
    done
	
    # Huggingface download full model with possible include/exclude to specified local directory	
	for i in $(seq 1 20); do
        VAR1="HF_FULL_MODEL${i}"
        DIR_VAR="HF_FULL_MODEL_LOCAL_DIR${i}"
        EXCLUDE_VAR="HF_FULL_MODEL_EXCLUDE${i}"
        INCLUDE_VAR="HF_FULL_MODEL_INCLUDE${i}"
        MODEL="${!VAR1}"
        DEST_DIR="${!DIR_VAR}"
        EXCLUDE="${!EXCLUDE_VAR}"
        INCLUDE="${!INCLUDE_VAR}"

        if [[ -z "$MODEL" ]]; then
            if [[ -n "$DEST_DIR" || -n "$EXCLUDE" || -n "$INCLUDE" ]]; then
                echo "⚠️ [HF_FULL_MODEL${i}] Skipping full download: ${VAR1} is not set"
            fi
            continue
        fi

        if [[ -z "$DEST_DIR" ]]; then
            echo "⚠️ [HF_FULL_MODEL${i}] Skipping full download: ${DIR_VAR} is not set"
            continue
        fi

        if [[ -n "$INCLUDE" ]]; then
            echo "ℹ️ [HF_FULL_MODEL${i}] Using include patterns from ${INCLUDE_VAR}: ${INCLUDE}"
        fi

        if [[ -n "$EXCLUDE" ]]; then
            echo "ℹ️ [HF_FULL_MODEL${i}] Using exclude patterns from ${EXCLUDE_VAR}: ${EXCLUDE}"
        fi

        download_HF "${VAR1}" "" "$DEST_DIR" "${EXCLUDE_VAR}" "${INCLUDE_VAR}"
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
