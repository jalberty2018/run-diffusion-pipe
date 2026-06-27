# ⚙️ Environment variables

## **Authentication Tokens**

| Token        | Environment Variable |
|--------------|----------------------|
| Huggingface  | `HF_TOKEN`           |
| Code Server  | `PASSWORD`           |
| SSH/SCP      | `PUBLIC_KEY`         |

`HF_TOKEN` is used by the Hugging Face CLI for gated or private repositories.
`PASSWORD` enables password authentication for Code Server. If it is not set, Code Server generates a password in `/root/.config/code-server/config.yaml`.
`PUBLIC_KEY` enables the SSH service and appends the key to `~/.ssh/authorized_keys`.

## Huggingface model configuration

| Type | Model | File or directory inside repo | `/workspace/models/<Directory>` | Include patterns | Exclude patterns |
|------|-------|--------------------------------|----------------------------------|------------------|------------------|
| Partial | `HF_MODEL[1-20]` | `HF_MODEL_NAME[1-20]` | `HF_MODEL_LOCAL_DIR[1-20]` | | |
| Full | `HF_FULL_MODEL[1-20]` | | `HF_FULL_MODEL_LOCAL_DIR[1-20]` | `HF_FULL_MODEL_INCLUDE[1-20]` | `HF_FULL_MODEL_EXCLUDE[1-20]` |

Use matching numbers for each download. For example, `HF_MODEL1`, `HF_MODEL_NAME1`, and `HF_MODEL_LOCAL_DIR1` describe one partial download.

### Partial download

Downloads one file or subdirectory from a Hugging Face repository:

```bash
HF_MODEL1=Comfy-Org/z_image
HF_MODEL_NAME1=split_files/vae/ae.safetensors
HF_MODEL_LOCAL_DIR1=zib
```

Result:

```text
/workspace/models/zib/ae.safetensors
```

### Full repository download

Downloads the complete repository into the target directory:

```bash
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_FULL_MODEL_LOCAL_DIR1=wan/ckpt_path
```

Result:

```text
/workspace/models/wan/ckpt_path/
```

### Full repository download with excludes

Use `HF_FULL_MODEL_EXCLUDE#` to skip files or directories. Separate multiple patterns with spaces:

```bash
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_FULL_MODEL_LOCAL_DIR1=wan/ckpt_path
HF_FULL_MODEL_EXCLUDE1="models_t5* */diffusion_pytorch_model*"
```

### Full repository download with includes

Use `HF_FULL_MODEL_INCLUDE#` to download only matching files or directories. Separate multiple patterns with spaces:

```bash
HF_FULL_MODEL1=Wan-AI/Wan2.2-T2V-A14B
HF_FULL_MODEL_LOCAL_DIR1=wan/ckpt_path
HF_FULL_MODEL_INCLUDE1="vae/* scheduler/*"
```

`HF_FULL_MODEL_INCLUDE#` and `HF_FULL_MODEL_EXCLUDE#` can be combined for the same numbered full download.

The startup script checks indexes `1` through `20` for both partial and full downloads.
Set `HF_DOWNLOAD_TIMEOUT` to change the timeout per Hugging Face download. The default is `10m`; values use the GNU `timeout` format, such as `30m` or `2h`.

## Workspace move configuration

On first pod start, `/diffusion-pipe` is copied to `/workspace/diffusion-pipe` with progress logging before the original image copy is removed.

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| `MOVE_STATUS_INTERVAL` | `5` | Seconds between move progress checks. |
| `MOVE_STALL_TIMEOUT` | `300` | Seconds without size changes before the move is treated as stalled. |

## Connection options

### Services

| Service         | Port          |
|-----------------|---------------|
| **Tensorboard** | `6006` (HTTP) |
| **Code Server** | `9000` (HTTP) |
| **SSH/SCP**     | `22`   (TCP)  |

