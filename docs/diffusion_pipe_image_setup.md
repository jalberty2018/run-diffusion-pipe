# ⚙️ Image setup

| Component | Version |
|-----------|---------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x` |
| PyTorch   | `2.9.0` |
| CUDA      | `12.8.1` |
| Triton    | `3.4.0` |
| nvcc      | `12.8.x` |
| diffusion pipe | cloned from upstream `main` during image build |
| code server | installed from official install script during image build |

## Installed Attentions

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention  | 2.2.0    |

### Build for

| Processor | Compute Capability | SM |
|-----------|--------------------|-------|
| RTX A5000 | 8.6 | sm_86 |
| RTX 4090 | 8.9 | sm_89 |

## Runtime services

| Service | Port | Starts when |
|---------|------|-------------|
| Code Server | `9000` | A GPU is detected by RunPod or `nvidia-smi` |
| TensorBoard | `6006` | PyTorch CUDA is available |
| SSH/SCP | `22` | `PUBLIC_KEY` is set |

TensorBoard reads logs from `/workspace/output`.
