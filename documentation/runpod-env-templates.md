# RunPod templates

## WAN 2.1 t2v

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_FULL_MODEL1=Wan-AI/Wan2.1-T2V-14B
HF_FULL_MODEL_LOCAL_DIR1=ckpt_path
```

## WAN 2.2 t2v high

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_FULL_MODEL_LOCAL_DIR1=wan/ckpt_path
HF_FULL_MODEL_EXCLUDE1="models_t5* */diffusion_pytorch_model*"
HF_MODEL1=Comfy-Org/Wan_2.2_ComfyUI_Repackaged
HF_MODEL_NAME1=split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors
HF_MODEL_LOCAL_DIR1=wan/transformer_path
HF_MODEL2=Comfy-Org/Wan_2.2_ComfyUI_Repackaged
HF_MODEL_NAME2=split_files/text_encoders/umt5_xxl_fp16.safetensors
HF_MODEL_LOCAL_DIR2=wan/llm_path
```

## WAN 2.2 t2v low

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_FULL_MODEL_LOCAL_DIR1=wan/ckpt_path
HF_FULL_MODEL_EXCLUDE1="models_t5* */diffusion_pytorch_model*"
HF_MODEL1=Comfy-Org/Wan_2.2_ComfyUI_Repackaged
HF_MODEL_NAME1=split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors
HF_MODEL_LOCAL_DIR1=wan/transformer_path
HF_MODEL2=Comfy-Org/Wan_2.2_ComfyUI_Repackaged
HF_MODEL_NAME2=split_files/text_encoders/umt5_xxl_fp16.safetensors
HF_MODEL_LOCAL_DIR2=wan/llm_path
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

## Flux-Klein 9B

```bash
HF_TOKEN="{{ RUNPOD_SECRET_HF_TOKEN_WRITE }}"
PASSWORD="{{ RUNPOD_SECRET_CODE-SERVER-NEW }}"
HF_MODEL1=black-forest-labs/FLUX.2-klein-base-9B
HF_MODEL_NAME1=flux-2-klein-base-9b.safetensors
HF_MODEL_LOCAL_DIR1=flux
HF_MODEL2=LS110824/text_encoders
HF_MODEL_NAME2=qwen_3_8b.safetensors
HF_MODEL_LOCAL_DIR2=flux
HF_MODEL3=Comfy-Org/vae-text-encorder-for-flux-klein-9b
HF_MODEL_NAME3=split_files/vae/flux2-vae.safetensors
HF_MODEL_LOCAL_DIR3=flux
```
