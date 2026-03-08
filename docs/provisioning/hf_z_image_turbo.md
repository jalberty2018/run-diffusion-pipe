# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
- [HF ComfyUI](https://huggingface.co/Comfy-Org/z_image_turbo/tree/main)
- [Training adaptor](https://huggingface.co/ostris/zimage_turbo_training_adapter)

## Diffusion_model

### bf16

```bash
hf download Comfy-Org/z_image_turbo split_files/diffusion_models/z_image_turbo_bf16.safetensors \
--local-dir /workspace/models
``` 
## CLIP Text encoder

```bash
hf download Comfy-Org/z_image_turbo split_files/text_encoders/qwen_3_4b.safetensors \
--local-dir /workspace/models
```
## Vae

```bash
hf download Comfy-Org/z_image_turbo split_files/vae/ae.safetensors \
--local-dir /workspace/models
```

## Training adaptor

```bash
hf downloaf ostris/zimage_turbo_training_adapter zimage_turbo_training_adapter_v2.safetensors \
--local-dir /workspace/models
```


