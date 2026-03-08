# ⚙️ Environment variables

## **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |


## Huggingface model configuration

| Type  | Model     | Safetensors |  /workspace/models/<Directory> |
|-------|-----------|------------------|---------------------------------|  
| File  | `HF_MODEL[1-20]`  | `HF_MODEL_FILENAME[1-20]`   | `HF_MODEL_DIR[1-20]` |
| Dir   | `HF_FULL_MODEL[1-20]`  |   | `HF_FULL_MODEL_DIR[1-20]` |

## Connection options 

### Services

| Service         | Port          |
|-----------------|---------------| 
| **Tensorboard** | `6006` (HTTP) |
| **Code Server** | `9000` (HTTP) |
| **SSH/SCP**     | `22`   (TCP)  |

