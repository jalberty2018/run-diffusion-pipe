# run-diffusion-pipe

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

- GPU RTX A5000 , A40 (cheapest options)
- Pod volume: 80Gb / 100 Gb (depending on your dataset and model size)

## Templates [RunPod.io](https://runpod.io?ref=se4tkc5o)

- [HunyuanVideo](https://console.runpod.io/deploy?template=5avqh2xkq3&ref=se4tkc5o)
- [WAN 2.2](https://console.runpod.io/deploy?template=w97tab8ql0&ref=se4tkc5o)

## Setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64`|
| Python    | `3.11.x`             |
| PyTorch   | `2.9.1`              |
| CUDA      | `12.8.x`             |
| Triton    | `3.4.x`              |
| onnxruntime-gpu | `1.22.x` |
| ComfyUI | Latest |
| CodeServer | Latest |

## Installed Attentions

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention  | 2.2.0    |

### Build for

| Processor | Compute Capability | SM |
|------------|-----------------|-----------|
| A40  | 8.6 | sm_86 |
| L40S | 8.9 | sm_89 |

## Environment Variables  

### **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |

### **Diffusion Models Setup WAN2.1 and WAN2.2**  

| Model Type        | Model                   |
|-------------------|-------------------------| 
| Checkpoint        | `HF_MODEL_CKPT`         |


### **Diffusion Models Setup Qwen-image, Omnigen2**  

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

## Supported models

- [doc](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
