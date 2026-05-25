# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
- [HF ComfyUI](https://huggingface.co/Comfy-Org/z_image)
- [Clip abliturated](https://huggingface.co/chinmankokumin/Qwen3-4B-abliterated-v2)

## Diffusion_model

### bf16

```bash
hf download Comfy-Org/z_image split_files/diffusion_models/z_image_bf16.safetensors \
--local-dir /workspace/models/zib/
``` 

## CLIP Text encoder

```bash
hf download chinmankokumin/Qwen3-4B-abliterated-v2 qwen_3_4b_abliterated_v2.safetensors \
--local-dir /workspace/models/zib/
```

## Vae

```bash
hf download Comfy-Org/z_image split_files/vae/ae.safetensors \
--local-dir /workspace/models/zib/
```



