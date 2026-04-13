# run-diffusion-pipe

## Synopsis

- Models are automatically downloaded based on the specified paths in the environment configuration.  
- Authentication credentials can be set via secrets for:  
  - **Code server** authentication (not possible to switch off) 
  - **Hugging Face** token for model access.  

Ensure that the required environment variables and secrets are correctly set before running the pod.
See below for options.

## Hardware provisioning

- GPU RTX A5000 , RTX 4090
- Pod volume: 60Gb / 80 Gb (depending on your dataset and model size)

## Image setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.9.0`              |
| CUDA      | `12.8.1`             |
| Triton    | `3.4.0`               |
| nvcc      | `12.8.x`            |
| diffusion pipe     | latest     |
| code server    | latest     |

## Installed Attentions

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention  | 2.2.0    |

### Build for

| Processor | Compute Capability | SM |
|------------|-----------------|-----------|
| RTX A5000  | 8.6 | sm_86b |
| RTX 4090 | 8.9 | sm_89 |

## Environment Variables  

### **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |

## Huggingface model configuration

| Type  | Model     | Safetensors |  /workspace/models/<Directory> |
|-------|-----------|------------------|---------------------------------|  
| File  | `HF_MODEL[1-20]`  | `HF_MODEL_FILENAME[1-20]`   | `HF_MODEL_DIR[1-20]` |
| Dir   | `HF_FULL_MODEL[1-20]`  |   | `HF_MODEL_DIR[1-20]` |

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
