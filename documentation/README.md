# run-diffusion-pipe

## Documentation

- [Resources](../docs/diffusion_pipe_resources.md)
- [Model provisioning](../docs/diffusion_pipe_provisioning.md)
- [Config examples](../docs/diffusion_pipe_config_examples.md)
- [Start training](../docs/diffusion_pipe_start_training.md)
- [Hardware Requirements](../docs/diffusion_pipe_hardware.md)
- [Image setup](../docs/diffusion_pipe_image_setup.md)
- [Environment variables](../docs/diffusion_pipe_configuration.md)

## Huggingface

```bash
export HF_TOKEN="xxxxx"
hf download model model_name.safetensors --local-dir /workspace/
hf upload model /workspace/model.safetensors
```

```bash
hf auth login --token xxxxx
```

## 7z Compression  

### **Encrypt & Archive Output**  

```bash
7z a -p -mhe=on /workspace/output/output-minimax-x.7z /workspace/output/
7z a -p -mhe=on -v800m /workspace/output/output-image-x.7z /workspace/output/
```

### **Extract Archive**  

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

## Utilities  

```bash
nvtop      # GPU Monitoring
nvidia-smi # GPU information
htop       # Process Monitoring  
mc         # Midnight Commander (file manager)  
nano       # Text Editor
ncdu       # Clean Up
unzip      # uncompress
age        # public/private key encryption
7z         # Archiving
runpodctl  # runpod pod management
```
