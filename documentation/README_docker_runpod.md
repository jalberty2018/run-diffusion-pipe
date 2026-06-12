# run-diffusion-pipe

- [Website](https://github.com/tdrussell/diffusion-pipe)

## Synopsis

- Models are automatically downloaded based on the specified paths in the environment configuration.
- Authentication credentials can be set via secrets for:
  - **Code server** authentication (not possible to switch off)
  - **Hugging Face** token for model access.

Ensure that the required environment variables and secrets are correctly set before running the pod.
See below for options.

## Hardware Requirements

- Volume: Models + dataset (3000 images/frames) + output (10 epochs)

| Model | GPU | Container Disk | Volume Disk |
|--------------|------------|------------|------------------|
| WAN 2.2 | RTX A5000 (24 GB) | 15 GB | 125 GB |
| LTX 2.3 | L40S (48 GB) | 15 GB | 100 GB |
| ZIB | RTX 4090 (24 GB) | 15 GB | 40 GB |
| FLUX-Klein-9B | RTX 4090 (24 GB) | 15 GB | 60 GB |

## Image setup

| Component | Version |
|-----------|---------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x` |
| PyTorch   | `2.9.0` |
| CUDA      | `12.8.1` |
| Triton    | `3.4.0` |
| nvcc      | `12.8.x` |
| diffusion pipe | latest |
| code server | latest |

## Installed Attentions

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention  | 2.2.0    |

### Build for

| Processor | Compute Capability | SM |
|------------|-----------------|-----------|
| RTX A5000  | 8.6 | sm_86 |
| RTX 4090 | 8.9 | sm_89 |

## Environment Variables

### **Authentication Tokens**

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |

## Huggingface model configuration

| Type  | Model     | Safetensors/Directory | /workspace/models/<Directory> |
|-------|-----------|-----------------------|--------------------------------|
| Partial  | `HF_MODEL[1-20]`  | `HF_MODEL_NAME[1-20]`   | `HF_MODEL_LOCAL_DIR[1-20]` |
| Full   | `HF_FULL_MODEL[1-20]`  |   | `HF_MODEL_LOCAL_DIR[1-20]` |

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
