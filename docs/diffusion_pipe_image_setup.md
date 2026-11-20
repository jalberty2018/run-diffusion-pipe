# ⚙️ Image setup

## Image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 24.04 x86_64` |
| Python    | `3.12.x`             |
| PyTorch   | `2.12.1+cu130`             |
| Torchvision | `0.27.1+cu130`           |
| Torchaudio | `2.11.0+cu130`            |
| CUDA      | `13.0`               |
| cuDNN     | `9`                  |
| Triton    | `3.7.1`              |
| CodeServer | `latest`          |

## Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.4`    |
| sageattention  |  `2.2.0`   |

## Optimised

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_86` | RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40S |
| Blackwell | 12.0 | `sm_120` | RTX 5090, RTX PRO 6000, PRO 6000 MiG |

## Runtime services

| Service | Port | Starts when |
|---------|------|-------------|
| Code Server | `9000` | A GPU is detected by RunPod or `nvidia-smi` |
| TensorBoard | `6006` | PyTorch CUDA is available |
| SSH/SCP | `22` | `PUBLIC_KEY` is set |

TensorBoard reads logs from `/workspace/output`.
