# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)
- [HF base 9B](https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9B)
- [HF Uncensored clip encoder](https://huggingface.co/ponpoke/flux2-klein-9b-uncensored-text-encoder)

## Diffusion_model

### Base 9B (gated)

```bash
hf download black-forest-labs/FLUX.2-klein-base-9B flux-2-klein-base-9b.safetensors \
--local-dir /workspace/models/flux/
``` 

## CLIP Text encoder

```bash
hf download LS110824/text_encoders qwen_3_8b.safetensors \
--local-dir /workspace/models/flux/
```

## Vae

```bash
hf download hf download Comfy-Org/vae-text-encorder-for-flux-klein-9b split_files/vae/flux2-vae.safetensors \
--local-dir /workspace/models/flux/
```
