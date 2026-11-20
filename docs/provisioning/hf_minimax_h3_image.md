# Provisioning

- [Documentation](https://github.com/tdrussell/diffusion-pipe/blob/main/docs/supported_models.md#minimax-h3-image)
- [HF MiniMax-H3-Image](https://huggingface.co/Comfy-Org/MiniMax-H3-Image)
- [HF MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3)
- [HF Qwen3 VL 32B Ultra Heretic](https://huggingface.co/ethanfel/Qwen3-VL-32B-Ultra-Heretic-MiniMax-H3-ComfyUI-INT8-ConvRot)
- [HF MiniMax-H3-Image Undistill LoRA](https://huggingface.co/circlestone-labs/MiniMax-H3-Image-Undistill-Lora)
- [Training config](../config_examples/minimax_h3_image_config.toml)

## Diffusion model

### Pruned INT8 ConvRot

```bash
hf download Comfy-Org/MiniMax-H3-Image diffusion_models/minimax_h3_image_pruned_int8_convrot.safetensors \
--local-dir /workspace/models/minimax-h3-image/
```

## Text encoder

```bash
hf download ethanfel/Qwen3-VL-32B-Ultra-Heretic-MiniMax-H3-ComfyUI-INT8-ConvRot qwen3vl_32b_h3_ultra_uncensored_heretic_int8_convrot.safetensors \
--local-dir /workspace/models/minimax-h3-image/
```

## Vae

```bash
hf download Comfy-Org/MiniMax-H3 vae/minimax_h3_video_vae_fp16.safetensors \
--local-dir /workspace/models/minimax-h3-image/
```

## Training adapter

```bash
hf download circlestone-labs/MiniMax-H3-Image-Undistill-Lora minimax_h3_image_undistill_lora.safetensors \
--local-dir /workspace/models/minimax-h3-image/loras/
```
