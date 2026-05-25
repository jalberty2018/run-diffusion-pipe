# Runpod templates

## WAN 2.1 t2v

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_FULL_MODEL1=Wan-AI/Wan2.1-T2V-14B
HF_MODEL_LOCAL_DIR1=ckpt_path
```

## WAN 2.2 t2v

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_MODEL_LOCAL_DIR1=ckpt_path
```

## LTX 2.3

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL1=DreamFast/gemma-3-12b-it-heretic-v2
HF_MODEL_NAME1=comfyui/gemma-3-12b-it-heretic-v2_fp8_e4m3fn.safetensors
HF_MODEL_LOCAL_DIR1=ltx23
HF_MODEL2=Lightricks/LTX-2.3
HF_MODEL_NAME2=ltx-2.3-22b-dev.safetensors
HF_MODEL_LOCAL_DIR2=ltx23
```

## Z-image Base

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL1=Comfy-Org/z_image
HF_MODEL_NAME1=split_files/diffusion_models/z_image_bf16.safetensors
HF_MODEL_LOCAL_DIR1=zib
HF_MODEL2=chinmankokumin/Qwen3-4B-abliterated-v2
HF_MODEL_NAME2=qwen_3_4b_abliterated_v2.safetensors
HF_MODEL_LOCAL_DIR2=zib
HF_MODEL3=Comfy-Org/z_image
HF_MODEL_NAME3=split_files/vae/ae.safetensors
HF_MODEL_LOCAL_DIR3=zib
```