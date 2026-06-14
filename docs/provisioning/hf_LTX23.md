# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md)

## Diffusion model

### [Lightricks](https://huggingface.co/Lightricks/LTX-2.3)

```bash
hf download Lightricks/LTX-2.3 ltx-2.3-22b-dev.safetensors \
--local-dir /workspace/models/ltx23
```

### [Sulphur-2-base](https://huggingface.co/SulphurAI/Sulphur-2-base)

```bash
hf download SulphurAI/Sulphur-2-base sulphur_dev_bf16.safetensors \
--local-dir /workspace/models/ltx23
```

## Encoder

## [Gemma-3-12b-it-heretic-v2](https://huggingface.co/DreamFast/gemma-3-12b-it-heretic-v2)

```bash
hf download DreamFast/gemma-3-12b-it-heretic-v2 comfyui/gemma-3-12b-it-heretic-v2_fp8_e4m3fn.safetensors \
--local-dir /workspace/models/ltx23
```
