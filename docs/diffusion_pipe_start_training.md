# Start training RTX A5000, A40, L40S

## WAN 2.1 and others

```bash
cd diffusion-pipe
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config.toml
```

## Qwen Image 

```bash
pip uninstall diffusers
pip install git+https://github.com/huggingface/diffusers
cd diffusion-pipe
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config.toml
```

## WAN 2.2

```bash 
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config_low.toml

deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x/config_high.toml
```

## Resume training (--resume_from_checkpoint)

```bash
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --resume_from_checkpoint --config /workspace/x/config.toml
```