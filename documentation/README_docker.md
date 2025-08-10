[![Docker Image Version](https://img.shields.io/docker/v/ls250824/run-diffusion-pipe)](https://hub.docker.com/r/ls250824/run-diffusion-pipe)

# run-diffusion-pipe on [RunPod.io](https://runpod.io?ref=se4tkc5o)

## Synopsis

A streamlined setup for running **diffusion-pipe** for **HunyuanVideo**, **WAN** **Omnigen2**, **Qwen-image**. 
This pod downloads models as specified in the **environment variables** set in the template


- Models are automatically downloaded based on the specified paths in the environment configuration.  
- Authentication credentials can be set via secrets for:  
  - **Code server** authentication (not possible to switch off) 
  - **Hugging Face** token for model access.  

Ensure that the required environment variables and secrets are correctly set before running the pod.
See below for options.

## Hardware provisioning

- [Runpod.io](https://runpod.io/)
- GPU RTX A5000 , A40 (cheapest options)
- Pod volume: 80Gb / 100 Gb (depending on your dataset and model size)

## Template [RunPod.io](https://runpod.io?ref=se4tkc5o)

- [HunyuanVideo](https://runpod.io/console/deploy?template=5avqh2xkq3&ref=se4tkc5o)
- [Wan21](https://runpod.io/console/deploy?template=w97tab8ql0&ref=se4tkc5o)
- [Wan22]()

## Setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.x x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.7.1`              |
| CUDA      | `12.8`               |

## Available Images

### Image

```txt
Base Image: ls250824/pytorch-cuda-ubuntu-develop:<version>
```

[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-develop)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-develop)

#### Custom Build: 

```bash
docker pull ls250824/run-diffusion-pipe:<version>
```

## Environment Variables  

### **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |

### **Diffusion Models Setup WAN2.1 and WAN2.2 **  

| Model Type        | Model                   |
|-------------------|-------------------------| 
| Checkpoint        | `HF_MODEL_CKPT`         |


### **Diffusion Models Setup Qwen-image, Omnigen2 **  

| Model Type        | Model                   |
|-------------------|-------------------------| 
| Diffusers         | `HF_MODEL_DIFFUSERS`    | 


### **Diffusion Models Setup Hunyuanvideo**  

| Model Type        | Model                   | Safetensors                        |
|-------------------|-------------------------|------------------------------------| 
| Diffusion Model   | `HF_MODEL_TRANSFORMER`  | `HF_MODEL_TRANSFORMER_SAFETENSORS` |
| VAE               | `HF_MODEL_VAE`          | `HF_MODEL_VAE_SAFETENSORS`         |
| LLM               | `HF_MODEL_LLM`          |                                    |
| CLIP              | `HF_MODEL_CLIP`         |                                    |

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

## Tutorial

- [Hunyuanvideo](https://civitai.com/articles/9798/training-a-lora-for-hunyuan-video-on-windows)
- [Wan](https://www.stablediffusiontutorials.com/2025/03/wan-lora-train.html)
- [Lora training](https://civitai.com/articles/3105/essential-to-advanced-guide-to-training-a-lora)

## Supported models

- [doc](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)

### Start training RTX A5000, A40, L40S

#### WAN 2.1 and others

```bash
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config.toml
```

### Qwen Image 

```bash
pip uninstall diffusers
pip install git+https://github.com/huggingface/diffusers
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config.toml
```

#### WAN 2.2

```bash 
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config_low.toml

deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config_high.toml
```

### Resume training (--resume_from_checkpoint)

```bash
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --resume_from_checkpoint --config /workspace/x/config.toml
```

### Start training RTX 4000

```bash
NCCL_P2P_DISABLE="1" NCCL_IB_DISABLE="1" deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config.toml
```

