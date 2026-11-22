#!/bin/bash

echo "ℹ️ Pod run-diffusion-pipe started"
echo "ℹ️ Wait until the message 🎉 Provisioning done, ready to train AI content 🎉. is displayed"


# Hugging Face CLI output tuned for RunPod plain logs.
export NO_COLOR=1
export HF_HUB_VERBOSITY=warning
export HF_HUB_DISABLE_PROGRESS_BARS=0
export HF_HUB_DISABLE_UPDATE_CHECK=1

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
export HAS_GPU_BLACKWELL=0
if command -v nvidia-smi >/dev/null 2>&1; then
  if nvidia-smi >/dev/null 2>&1; then
    HAS_GPU=1
    GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader | xargs | sed 's/,/, /g')
    echo "✅ [GPU DETECTED] Found via nvidia-smi → Model(s): ${GPU_MODEL}"

    # Blackwell GPUs use CUDA compute capability 10.x or newer. Fall back to
    # known Blackwell product names when the installed nvidia-smi does not
    # expose the compute_cap query field.
    GPU_COMPUTE_CAPS="$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader 2>/dev/null || true)"
    if awk -F. '$1 + 0 >= 10 { found=1 } END { exit !found }' <<< "$GPU_COMPUTE_CAPS" \
       || grep -Eqi 'Blackwell|(^|[^[:alnum:]])(GB[0-9]{2,3}|B100|B200|B300|GeForce[[:space:]]+RTX[[:space:]]+50[0-9]{2}|RTX[[:space:]]+PRO[[:space:]]+6000)($|[^[:alnum:]])' <<< "$GPU_MODEL"; then
      export HAS_GPU_BLACKWELL=1
      echo "✅ [BLACKWELL GPU DETECTED] HAS_GPU_BLACKWELL=1"
    else
      echo "ℹ️ [NO BLACKWELL GPU] HAS_GPU_BLACKWELL=0"
    fi
  else
    echo "⚠️ [NO GPU] nvidia-smi found but failed to run (driver or permission issue)"
  fi
else
  echo "⚠️ [NO GPU] No GPU found via nvidia-smi"
fi

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

# Move necessary files to workspace
if [[ ( "$HAS_GPU" -eq 1 || "$HAS_GPU_RUNPOD" -eq 1 ) && "$HAS_CUDA" -eq 1 ]]; then
	echo "ℹ️ [Moving necessary files to workspace] enabling Start/Stop/Restart pod without data loss."
	
	for script in diffusion-pipe-on-workspace.sh readme-on-workspace.sh docs-on-workspace.sh; do
	    if [ -f "/$script" ]; then
	        echo "Executing $script..."
	        "/$script"
	    else
	        echo "⚠️ BUG: Skipping $script (not found)"
	    fi
	done
fi

# Start code-server (HTTP port 9000) 
if [[ "$HAS_GPU" -eq 1 || "$HAS_GPU_RUNPOD" -eq 1 ]]; then    
    echo "▶️ Code-Server service starting"
	
    if [[ -n "$PASSWORD" ]]; then
        code-server /workspace --auth password --disable-update-check --disable-telemetry --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    else
        echo "⚠️ PASSWORD is not set as an environment. Password file: /root/.config/code-server/config.yaml"
        code-server /workspace --disable-telemetry --disable-update-check --host 0.0.0.0 --bind-addr 0.0.0.0:9000 &
    fi
	
    echo "🎉 code-server service started"
    sleep 1
else
    echo "⚠️ WARNING: No GPU available, Code Server not started to limit memory use"
fi

if [[ "$HAS_CUDA" -eq 1 ]]; then  	
    echo "✅ Starting Tensorboard service"

	# Start TensorBoard on port 6006
    tensorboard --logdir /workspace/output --host 0.0.0.0 &
else
    echo "❌ ERROR: PyTorch CUDA driver mismatch or unavailable, tensorboard not started"
fi
	
# Create workspace directories if they don’t exist
mkdir -p /workspace/output
mkdir -p /workspace/models

show_runpod_services() {
    if [[ "$HAS_GPU_RUNPOD" -ne 1 ]]; then
        return 0
    fi

    local output
    # Buffer all output until the health checks have finished.
    output="$(exec 2>&1
        echo "ℹ️ Connect to the following services from console menu or url ℹ️"

        if [[ -z "${RUNPOD_POD_ID:-}" ]]; then
            echo "⚠️ RUNPOD_POD_ID not set — service URLs unavailable"
            return 0
        fi

        local service
        local port
        local url
        local local_url
        local http_code
        local -A services=(
          ["Code-Server"]=9000
          ["Tensorboard"]=6006
        )

        # Local health checks (inside the pod)
        for service in "${!services[@]}"; do
            port="${services[$service]}"
            url="https://${RUNPOD_POD_ID}-${port}.proxy.runpod.net"
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
    )"
    printf '%s\n' "$output"
}

show_code_server_login() {
    if [[ -n "$PASSWORD" ]]; then
        echo "ℹ️ Code-Server login use PASSWORD set as env ℹ️"
    else
        echo "⚠️ Code-Server login use the logged password ⚠️"
        cat /root/.config/code-server/config.yaml
    fi
}

# Provisioning routines

report_download_space_error() {
    local message="${1,,}"
    if [[ "$message" == *"no space left on device"* || "$message" == *"enospc"* ]]; then
        echo "❌ [DOWNLOAD] No space left on device"
        wget -q --timeout=5 --tries=1 -O /dev/null "https://provisioning.rozenlaan.site/minimax/++no-space-left-${BUILD_TAG}.json" || true
        return 0
    fi
    return 1
}

run_hf_download() {
    local stall_timeout="${HF_DOWNLOAD_STALL_TIMEOUT:-300}"
    local kill_after="${HF_DOWNLOAD_KILL_AFTER:-30}"
    local hf_command
    local hf_dry_run_command
    local dry_run_output
    local total_size_value
    local total_size_unit
    local total_bytes=0
    local tmp_dir
    local fifo
    local pid
    local watchdog_pid
    local progress_pid
    local last_activity_file
    local activity_tmp_file
    local progress_activity_tmp_file
    local exit_code
    local fallback=0
    local download_dir=""
    local -a download_args=("$@")
    local arg_index

    for ((arg_index = 0; arg_index < ${#download_args[@]}; arg_index++)); do
        if [[ "${download_args[arg_index]}" == "--local-dir" ]] \
           && (( arg_index + 1 < ${#download_args[@]} )); then
            download_dir="${download_args[arg_index + 1]}"
            break
        fi
    done

    echo "ℹ️ [DOWNLOAD] Stall watchdog: ${stall_timeout}s"
    echo "ℹ️ [DOWNLOAD] Kill grace period: ${kill_after}s"
    echo "ℹ️ [DOWNLOAD] Updated every 5s"


    # Safely quote all arguments passed to: hf download
    # Force human output so progress bars remain enabled when the command is
    # captured through the pseudo-terminal and FIFO below.
    printf -v hf_command '%q ' hf download --format human "$@"

    # Ask the Hub for the selected file size before starting. The dry run uses
    # the same repository, file filters, authentication and destination as the
    # real download, but does not transfer the model itself.
    printf -v hf_dry_run_command '%q ' hf download --dry-run --format human "$@"
    dry_run_output="$(eval "$hf_dry_run_command" 2>&1 || true)"
    report_download_space_error "$dry_run_output" || true
    if [[ "$dry_run_output" =~ totalling[[:space:]]+([0-9]+([.][0-9]+)?)([KMGTPE]?) ]]; then
        total_size_value="${BASH_REMATCH[1]}"
        total_size_unit="${BASH_REMATCH[3]}"
        total_bytes="$(awk -v value="$total_size_value" -v unit="$total_size_unit" '
            BEGIN {
                exponent = index("KMGTPE", unit)
                multiplier = 1
                for (i = 0; i < exponent; i++) multiplier *= 1000
                printf "%.0f", value * multiplier
            }
        ')"
        printf 'ℹ️ [DOWNLOAD] Total size: %.2f GB\n' "$(awk -v bytes="$total_bytes" 'BEGIN { print bytes / 1000000000 }')"
    else
        echo "⚠️ [DOWNLOAD] Total size could not be determined; continuing download."
    fi

    tmp_dir="$(mktemp -d)"
    fifo="${tmp_dir}/hf-output.fifo"
    last_activity_file="${tmp_dir}/last_activity"
    activity_tmp_file="${tmp_dir}/last_activity.tmp"
    progress_activity_tmp_file="${tmp_dir}/last_activity.progress.tmp"

    mkfifo "$fifo"
    # Write to a separate file first so the watchdog can never observe a
    # timestamp file that has been truncated but not written yet.
    date +%s > "$activity_tmp_file"
    mv -f "$activity_tmp_file" "$last_activity_file"

    cleanup() {
        [[ -n "${watchdog_pid:-}" ]] && kill "$watchdog_pid" 2>/dev/null || true
        [[ -n "${progress_pid:-}" ]] && kill "$progress_pid" 2>/dev/null || true
        [[ -n "${pid:-}" ]] && kill "$pid" 2>/dev/null || true
        rm -rf "$tmp_dir"
    }

    trap cleanup RETURN

    run_download_attempt() {
        local disable_xet="$1"
        local backend_name="$2"
        local space_error_reported=0
        local watchdog_exit_code=0
        local timeout_marker="${tmp_dir}/watchdog-timeout"

        rm -f "$timeout_marker"

        date +%s > "$activity_tmp_file"
        mv -f "$activity_tmp_file" "$last_activity_file"

        echo "ℹ️ [DOWNLOAD] Starting with ${backend_name}..."

        (
            script --quiet --return --flush \
                --command "HF_HUB_DISABLE_XET=${disable_xet} ${hf_command}" \
                /dev/null
        ) >"$fifo" 2>&1 &

        pid=$!

        # Xet does not always emit its own progress bar when its output is
        # captured. Report growth of the local download directory instead.
        # Only actual byte growth refreshes the stall watchdog.
        if [[ -n "$download_dir" ]]; then
            (
                local baseline_bytes
                local previous_bytes
                local current_bytes
                local downloaded_bytes
                local downloaded_gb
                local speed_mbps
                local previous_sample_time
                local current_sample_time
                local elapsed_seconds
                local interval_bytes

                baseline_bytes="$(du -s -B1 "$download_dir" 2>/dev/null | awk '{print $1}')"
                baseline_bytes="${baseline_bytes:-0}"
                previous_bytes="$baseline_bytes"
                previous_sample_time="$(date +%s)"

                while kill -0 "$pid" 2>/dev/null; do
                    sleep 10
                    current_bytes="$(du -s -B1 "$download_dir" 2>/dev/null | awk '{print $1}')"
                    current_bytes="${current_bytes:-0}"
                    current_sample_time="$(date +%s)"

                    if (( current_bytes > previous_bytes )); then
                        downloaded_bytes=$((current_bytes - baseline_bytes))
                        interval_bytes=$((current_bytes - previous_bytes))
                        elapsed_seconds=$((current_sample_time - previous_sample_time))
                        (( elapsed_seconds < 1 )) && elapsed_seconds=1
                        downloaded_gb="$(awk -v bytes="$downloaded_bytes" 'BEGIN { printf "%.2f", bytes / 1000000000 }')"
                        speed_mbps="$(awk -v bytes="$interval_bytes" -v seconds="$elapsed_seconds" 'BEGIN { printf "%.1f", bytes / seconds / 1000000 }')"
                        if (( total_bytes > 0 )); then
                            printf '⬇️ [DOWNLOAD] Progress: %s / %.2f GB | %s MB/s\n' \
                                "$downloaded_gb" \
                                "$(awk -v bytes="$total_bytes" 'BEGIN { print bytes / 1000000000 }')" \
                                "$speed_mbps"
                        else
                            printf '⬇️ [DOWNLOAD] Progress: %s GB downloaded | %s MB/s\n' \
                                "$downloaded_gb" "$speed_mbps"
                        fi
                        date +%s > "$progress_activity_tmp_file"
                        mv -f "$progress_activity_tmp_file" "$last_activity_file"
                    else
                        echo "ℹ️ [DOWNLOAD] Waiting for transfer progress..."
                    fi

                    previous_bytes="$current_bytes"
                    previous_sample_time="$current_sample_time"
                done
            ) &
            progress_pid=$!
        fi

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
                last="$(cat "$last_activity_file" 2>/dev/null || true)"

                # Ignore a missing or malformed sample instead of interpreting
                # it as epoch zero and reporting decades of inactivity.
                if [[ ! "$last" =~ ^[0-9]+$ ]] || (( last > now )); then
                    continue
                fi

                inactive=$((now - last))

                if (( inactive >= stall_timeout )); then
                    echo
                    echo "⚠️ [DOWNLOAD] No activity for ${inactive}s."
                    echo "⚠️ [DOWNLOAD] ${backend_name} appears stalled."

                    # Record the timeout before stopping the download so the
                    # parent cannot cancel the watchdog during its grace period.
                    touch "$timeout_marker"
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
            date +%s > "$activity_tmp_file"
            mv -f "$activity_tmp_file" "$last_activity_file"

            printf '%s\n' "$line"
            if (( space_error_reported == 0 )) && report_download_space_error "$line"; then
                space_error_reported=1
            fi
        done < <(
            stdbuf -oL tr '\r' '\n' <"$fifo" \
                | sed -u -E \
                    -e '/^[[:space:]]*$/d' \
                    -e $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' \
                    -e 's/^([^:]+):[[:space:]]*([0-9]+)%\|[^|]*\|[[:space:]]*([^[:space:]]+).*/Downloading \1 \2% \3/'
        )

        wait "$pid"
        exit_code=$?

        if [[ ! -f "$timeout_marker" ]]; then
            kill "$watchdog_pid" 2>/dev/null || true
        fi
        wait "$watchdog_pid" 2>/dev/null || watchdog_exit_code=$?
        if [[ "$watchdog_exit_code" -eq 124 || -f "$timeout_marker" ]]; then
            exit_code=124
        fi
        [[ -n "${progress_pid:-}" ]] && kill "$progress_pid" 2>/dev/null || true
        [[ -n "${progress_pid:-}" ]] && wait "$progress_pid" 2>/dev/null || true

        pid=""
        watchdog_pid=""
        progress_pid=""

        return "$exit_code"
    }

    #
    # Attempt 1: Xet
    #
    if run_download_attempt 0 "Xet"; then
        echo "✅ [DOWNLOAD] Download completed successfully with Xet."
        return 0
    else
        exit_code=$?
    fi

    echo "⚠️ [DOWNLOAD] Xet download stopped or failed with exit code ${exit_code}."
    echo "ℹ️ [DOWNLOAD] Retrying with Xet disabled (plain HTTP)..."

    #
    # Attempt 2: plain HTTP
    #
    if run_download_attempt 1 "plain HTTP"; then
        echo "✅ [DOWNLOAD] Download completed successfully using plain HTTP."
        return 0
    else
        exit_code=$?
    fi

    echo "❌ [DOWNLOAD] Plain HTTP download failed with exit code ${exit_code}."
    return "$exit_code"
}

download_generic_HF() {
    local model_var="$1"
    local file_var="$2"
    local dest_dir="$3"
    local include_var="${4:-}"
    local exclude_var="${5:-}"

    local model="${!model_var}"
    [[ -z "$model" ]] && return 0

    local file=""
    if [[ -n "$file_var" ]]; then
        file="${!file_var}"
    fi

    local target="/workspace/models/$dest_dir"
    mkdir -p "$target"

    local status="ok"
    local hf_args=()
    local patterns=()
    local pattern

    if [[ -n "$include_var" && -n "${!include_var}" ]]; then
        IFS=$' \t\n' read -r -d '' -a patterns <<< "${!include_var}" || true
        for pattern in "${patterns[@]}"; do
            hf_args+=(--include "$pattern")
        done
    fi

    if [[ -n "$exclude_var" && -n "${!exclude_var}" ]]; then
        IFS=$' \t\n' read -r -d '' -a patterns <<< "${!exclude_var}" || true
        for pattern in "${patterns[@]}"; do
            hf_args+=(--exclude "$pattern")
        done
    fi

    if [[ -n "$file" ]]; then
        echo "ℹ️ [DOWNLOAD] Fetching $model/$file → $target"
        run_hf_download "$model" "$file" "${hf_args[@]}" --local-dir "$target"
        local rc=$?
    else
        echo "ℹ️ [DOWNLOAD] Fetching $model → $target"
        run_hf_download "$model" "${hf_args[@]}" --local-dir "$target"
        local rc=$?
    fi

    # ----------- SUCCESS ----------
    if [[ $rc -eq 0 ]]; then
        echo "✅ HF download completed"
        return 0
    fi

    # ---- SEGFAULT AFTER SUCCESS ---
    if [[ $rc -eq 139 && -f "$target/$file" ]]; then
        echo "⚠️ HF segfault after download (file exists → OK)"
        sleep 1
        return 0
    fi

    # ------------ TIMEOUT ----------
    if [[ $rc -eq 124 ]]; then
        echo "⚠️ HF download timed out"
        sleep 1
        return 0
    fi

    # -------- REAL FAILURE --------
    echo "❌ HF download failed (exit=$rc)"
    sleep 1
    return 0
}

# Provisioning if running on GPU with CUDA
if [[ "$HAS_CUDA" -eq 1 ]]; then  
   echo "📥 Provisioning models"
   
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

        download_generic_HF "${VAR1}" "${VAR2}" "$DEST_DIR"
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

        download_generic_HF "${VAR1}" "" "$DEST_DIR" "${INCLUDE_VAR}" "${EXCLUDE_VAR}"
    done

   HAS_PROVISIONING=1
else
   HAS_PROVISIONING=0   
   echo "⚠️ Skipped Provisioning: No models downloaded as no gpu cuda"
fi

# Environment
echo "ℹ️ Running environment check"

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

if triton is not None:
    print(f"Triton version: {triton.__version__}")
else:
    print("Triton: not available")
PY

if [[ "$HAS_PROVISIONING" -eq 1 ]]; then 
    echo "🎉 Provisioning done, ready to create AI content 🎉"

    show_runpod_services
    show_code_server_login

    echo "🎉 Provisioning done, ready to create AI content 🎉"
else
    echo "⚠️ Diagnostics, skipped provisioning ⚠️"

    if [[ "$HAS_GPU_RUNPOD" -eq 0 ]]; then
        echo "⚠️ Pod started without a runpod GPU"
    fi

    if [[ "$HAS_CUDA" -eq 0 ]]; then
        echo "❌ Pytorch CUDA driver error/mismatch/not available"
        if [[ "$HAS_GPU_RUNPOD" -eq 1 ]]; then
            echo "⚠️ [SOLUTION 1] Deploy pod on another region then $RUNPOD_DC_ID. ⚠️"
			echo "⚠️ [SOLUTION 2] Specify CUDA 13.0 using the runpod console filter. ⚠️"
        fi
    fi

    if [[ "$HAS_CUDA" -eq 1 && "$HAS_COMFYUI" -eq 0 ]]; then
        echo "❌ ComfyUI is not online (extreme slow vCPU's)"
        echo "⚠️ [SOLUTION 1] restart pod ⚠️"
		echo "⚠️ [SOLUTION 2] Deploy pod on another region then ${RUNPOD_DC_ID:-unknown} ⚠️"
    fi
fi

# Keep the container running
echo "ℹ️ End script"
exec sleep infinity