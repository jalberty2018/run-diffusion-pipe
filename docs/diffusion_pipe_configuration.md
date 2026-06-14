# ⚙️ Environment variables

## **Authentication Tokens**  

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |


## Huggingface model configuration

| Type  | Model     | Safetensors/Directory |  /workspace/models/<Directory> | --exclude |
|-------|-----------|------------------|---------------------------------|  
| Partial  | `HF_MODEL[1-20]`  | `HF_MODEL_NAME[1-20]`   | `HF_MODEL_LOCAL_DIR[1-20]` |
| Full   | `HF_FULL_MODEL[1-20]`  |   | `HF_FULL_MODEL_LOCAL_DIR[1-20]` | `HF_FULL_MODEL_EXCLUDE[1-20]` |

## Connection options 

### Services

| Service         | Port          |
|-----------------|---------------| 
| **Tensorboard** | `6006` (HTTP) |
| **Code Server** | `9000` (HTTP) |
| **SSH/SCP**     | `22`   (TCP)  |

