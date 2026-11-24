# run-diffusion-pipe

- [Website](https://github.com/tdrussell/diffusion-pipe)

## Synopsis

- Models are automatically downloaded based on the specified paths in the environment configuration.
- `/workspace` is persistent on RunPod. On first start the container moves `diffusion-pipe`, `README.md`, and `docs/` into `/workspace`.
- Code Server starts on port `9000` and TensorBoard starts on port `6006` when CUDA 13.x is available.
- Authentication credentials can be set via secrets for:
  - **Code server** authentication (not possible to switch off)
  - **Hugging Face** token for model access.
  - **SSH/SCP** access when `PUBLIC_KEY` is set or configured on runpod.

Ensure that the required environment variables and secrets are correctly set before running the pod.
See below for options.

## Hardware Requirements

- Volume: Models + dataset (3000 images/frames) + output (10 epochs)

| Model | GPU | Container Disk | Volume Disk | Block swap |
|--------------|------------|------------|------------------|------|
| WAN 2.2     | RTX A5000 (24 Gb) | 15 Gb |   80 Gb   | 0 |
| LTX 2.3   | L40S (48 Gb) | 15 Gb | 100 Gb  | 0 |
| ZIB   | RTX 4090 (24 Gb) | 15 Gb | 40 Gb | 0 |
| FLUX-Klein-9B   | RTX 4090 (24 Gb) | 15 Gb |  60 Gb | 0 |
| Krea-2   | RTX 4090 (24 Gb) | 15 Gb |  60 Gb | 0 |
| Minimax-H3-Image | RTX 4090 (24 Gb) | 15 Gb |  70 Gb | 15-20 |

## Image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 24.04 x86_64` |
| Python    | `3.12.x`             |
| PyTorch   | `2.12.1+cu130`             |
| Torchvision | `0.27.1+cu130`           |
| Torchaudio | `2.11.0+cu130`            |
| CUDA      | `13.0`               |
| cuDNN     | `9`                  |
| Triton    | `3.7.1`              |
| CodeServer | `latest`          |

## Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.4`    |
| sageattention  |  `2.2.0`   |

## Optimised

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_86` | RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40S |
| Blackwell | 12.0 | `sm_120` | RTX 5090, RTX PRO 6000, PRO 6000 MiG |

## Configuration (optional)

| Variable | Purpose |
|---|---|
| `PASSWORD` | Protect Code Server and pod tools (automatic if not set) |
| `HF_TOKEN` | Gated/private Hugging Face downloads |

## Huggingface model configuration

| Type | Model | File or directory inside repo | `/workspace/models/<Directory>` | Include patterns | Exclude patterns |
|------|-------|--------------------------------|----------------------------------|------------------|------------------|
| Partial | `HF_MODEL[1-20]` | `HF_MODEL_NAME[1-20]` | `HF_MODEL_LOCAL_DIR[1-20]` | | |
| Full | `HF_FULL_MODEL[1-20]` | | `HF_FULL_MODEL_LOCAL_DIR[1-20]` | `HF_FULL_MODEL_INCLUDE[1-20]` | `HF_FULL_MODEL_EXCLUDE[1-20]` |

### Workspace move

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| `MOVE_STATUS_INTERVAL` | `5` | Seconds between `/diffusion-pipe` to `/workspace/diffusion-pipe` progress checks. |
| `MOVE_STALL_TIMEOUT` | `300` | Seconds without size changes before the move is treated as stalled. |

## Connection options

### Services

| Service         | Port          |
|-----------------|---------------|
| **Tensorboard** | `6006` (HTTP) |
| **Code Server** | `9000` (HTTP) |
| **SSH/SCP**     | `22`   (TCP)  |

## Websites

- [diffusion-pipe](https://github.com/tdrussell/diffusion-pipe)
- [code server](https://github.com/coder/code-server)
- [tensorboard](https://www.tensorflow.org/tensorboard)
- [huggingface hub](https://huggingface.co/docs/huggingface_hub/index)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)

## Supported models

- [doc](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
