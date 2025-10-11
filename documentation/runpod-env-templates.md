# Runpod templates

## public

### WAN 2.2

```bash
HF_MODEL_CKPT=Wan-AI/Wan2.2-T2V-A14B
```

## private

### HunyuanVideo

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL_TRANSFORMER=Kijai/HunyuanVideo_comfy
HF_MODEL_TRANSFORMER_SAFETENSORS=hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors
HF_MODEL_VAE=Kijai/HunyuanVideo_comfy
HF_MODEL_VAE_SAFETENSORS=hunyuan_video_vae_bf16.safetensors
HF_MODEL_LLM=Kijai/llava-llama-3-8b-text-encoder-tokenizer
HF_MODEL_CLIP=openai/clip-vit-large-patch14
```

### WAN 2.1

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL_CKPT=Wan-AI/Wan2.1-T2V-14B
```

### WAN 2.2

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL_CKPT=Wan-AI/Wan2.2-T2V-A14B
```

### Qwen Image

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL_DIFFUSERS=Qwen/Qwen-Image
```
