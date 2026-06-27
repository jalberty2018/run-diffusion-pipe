# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
- [HF Krea-2](https://huggingface.co/Comfy-Org/Krea-2)
- [HF Huihui Qwen3 VL 4B abliterated](https://huggingface.co/ahmed22xa/Huihui-Qwen3-VL-4B-Instruct-abliterated-comfy)

## Diffusion model

### Raw bf16

```bash
hf download Comfy-Org/Krea-2 diffusion_models/krea2_raw_bf16.safetensors \
--local-dir /workspace/models/krea2/
```

## Text encoder

```bash
hf download ahmed22xa/Huihui-Qwen3-VL-4B-Instruct-abliterated-comfy Huihui-Qwen3-VL-4B-Instruct-abliterated.safetensors \
--local-dir /workspace/models/krea2/text-encoder
```

## Vae

```bash
hf download Comfy-Org/Krea-2 vae/qwen_image_vae.safetensors \
--local-dir /workspace/models/krea2/
```
