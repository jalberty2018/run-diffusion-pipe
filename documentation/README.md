# run-diffusion-pipe

## Documentation

- [Resources](../docs/diffusion_pipe_resources.md)
- [Model provisioning](../docs/diffusion_pipe_provisioning.md)
- [Config examples](../docs/diffusion_pipe_config_examples.md)
- [Start training](../docs/diffusion_pipe_start_training.md)
- [Hardware Requirements](../docs/diffusion_pipe_hardware.md)
- [Image setup](../docs/diffusion_pipe_image_setup.md)
- [Environment variables](../docs/diffusion_pipe_configuration.md)
- [RunPod environment templates](runpod-env-templates.md)

## Runtime layout

The image is built with `diffusion-pipe`, this README, and the `docs/` directory under `/`.
On first pod start these files are moved to `/workspace` so they survive pod restarts:

| Source in image | Persistent path |
|-----------------|-----------------|
| `/diffusion-pipe` | `/workspace/diffusion-pipe` |
| `/README.md` | `/workspace/README.md` |
| `/docs` | `/workspace/docs` |

Symlinks keep `/diffusion-pipe` and `/docs` available for commands and documentation that use the original paths.

## 7z

### Add directory to encrypted archive

```bash
7z a -p -mhe=on /workspace/output-training.7z /workspace/output/
7z a -p -mhe=on -v800m /workspace/output-image-x.7z /workspace/output/

```

### Extract directory from archive

```bash
7z x x.7z
```

## Start training

```bash
deepspeed --num_gpus=1 /workspace/diffusion-pipe/train.py --deepspeed --config /workspace/x_config.toml
```

## tmux

| Action           | Combination                   |
| --------------- | ----------------------- |
| Detach          | `Ctrl+b d`              |
| New window   | `Ctrl+b c`              |
| Next window | `Ctrl+b n`              |
| Previous window   | `Ctrl+b p`              |
| List sessions   | `tmux ls`               |
| Reconnect   | `tmux attach -t sessie` |

## Bash commands

```bash
nvtop
htop
ncdu
tmux
unzip
nvcc
nano
vim
ncdu
```