# syntax=docker/dockerfile:1.7
# pytorch 2.12.1
FROM  ls250824/pytorch-cuda-ubuntu-develop:22092026

# Set working directory
WORKDIR /

# Pin
COPY constraints.txt /constraints.txt

# Install Hugging Face CLI before downloading the wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
        huggingface_hub

# Download and install the GPU artifacts.
RUN --mount=type=cache,target=/root/.cache/pip \
    hf download LS110824/attentions-llama-cuda130 \
        flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
        --local-dir / \
    && python -m pip install \
        --no-cache-dir \
        --root-user-action ignore \
        -c /constraints.txt \
        ./flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        ./sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
    && rm -f \
        flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        sageattention-2.2.0-cp312-cp312-linux_x86_64.whl

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh           

# Clone latest default branch HEAD of diffusion pipe
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --recurse-submodules --depth 1 https://github.com/tdrussell/diffusion-pipe.git

RUN --mount=type=cache,target=/root/.cache/pip \
  python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
    -r diffusion-pipe/requirements.txt

# Copy start script
COPY --chmod=755 start.sh onworkspace/diffusion-pipe-on-workspace.sh onworkspace/docs-on-workspace.sh onworkspace/readme-on-workspace.sh /

# Copy supporting files
COPY --chmod=664 /documentation/README.md /README.md
COPY --chmod=644 docs/ /docs

# Set working directory for runtime
WORKDIR /workspace

# Expose ports
EXPOSE 9000 6006

# Labels
LABEL org.opencontainers.image.title="Diffusion-Pipe" \
      org.opencontainers.image.description="Pytorch 2.12.1 CUDA 13.0 devel + code-server + diffusion pipe" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/run-diffusion-pipe" \
      org.opencontainers.image.licenses="MIT"

# Update Hugging Face CLI and verify the hf command is available
RUN hf update && hf version

# CPU-safe package and artifact verification. Docker builds have no GPU/driver,
RUN python - <<'PY'
import importlib.metadata as metadata
import os
from pathlib import Path

packages = (
    "torch",
    "torchvision",
    "torchaudio",
    "triton",
)
for package in packages:
    print(f"{package}: {metadata.version(package)}")
PY

# Start the container
CMD ["/start.sh"]
