# Provisioning Hunyuanvideo

## transformer

```bash
huggingface-cli download Kijai/HunyuanVideo_comfy hunyuan_video_720_cfgdistill_bf16.safetensors \
--local-dir /workspace/models/transformer/
```

```bash
huggingface-cli download Kijai/HunyuanVideo_comfy hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors \
--local-dir /workspace/models/transformer/
```

## vae

```bash
huggingface-cli download Kijai/HunyuanVideo_comfy hunyuan_video_vae_bf16.safetensors \
--local-dir /workspace/models/vae/
```

## llm

```bash
huggingface-cli download Kijai/llava-llama-3-8b-text-encoder-tokenizer \
--local-dir /workspace/models/llm/
```

## clip

```bash
huggingface-cli download openai/clip-vit-large-patch14 \
--local-dir /workspace/models/clip/
```

