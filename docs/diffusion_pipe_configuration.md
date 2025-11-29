# ⚙️ Environment variables

## **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |

## **Diffusion Models Setup WAN2.1 and WAN2.2**  

| Model Type        | Model                   |
|-------------------|-------------------------| 
| Checkpoint        | `HF_MODEL_CKPT`         |


## **Diffusion Models Setup Qwen-image, Omnigen2**  

| Model Type        | Model                   |
|-------------------|-------------------------| 
| Diffusers         | `HF_MODEL_DIFFUSERS`    | 

## **Diffusion Models Setup Hunyuanvideo**  

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

