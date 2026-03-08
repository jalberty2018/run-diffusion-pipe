# run-diffusion-pipe

## Documentation

- [Resources](/workspace/docs/diffusion_pipe_resources.md)
- [Model provisioning](/workspace/docs/diffusion_pipe_provisioning.md)
- [Config examples](/workspace/docs/diffusion_pipe_config_examples.md)
- [Start training](/workspace/docs/diffusion_pipe_start_training.md)
- [Hardware Requirements](/workspace/docs/diffusion_pipe_hardware.md)
- [Image setup](/workspace/docs/diffusion_pipe_image_setup.md)
- [Environment variables](/workspace/docs/diffusion_pipe_configuration.md)

## 7z

### Add directory to encrypted archive

```bash
7z a -p -mhe=on output-training.7z /workspace/output/
```

### Extract directory from archive

```bash
7z x x.7z
```

## Split-Join

### Split

```bash
split -n 3 x.7z x_part
```

### Join files

```bash
cat x_part* > x.7z
```

## Bash commands

```bash
nvtop
htop
ncdu
tmux
tmux attach
unzip
nvcc
nano
vim
ncdu
```
