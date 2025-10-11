# syntax=docker/dockerfile:1.7
FROM ls250824/pytorch-cuda-ubuntu-develop:22082025

# Set working directory
WORKDIR /

# Copy start script
COPY --chmod=755 start.sh onworkspace/diffusion-pipe-on-workspace.sh onworkspace/config_examples-on-workspace.sh onworkspace/provisioning-on-workspace.sh onworkspace/readme-on-workspace.sh /

# Copy supporting files
COPY --chmod=664 /documentation/README.md /README.md

# Copy config_examples
COPY --chmod=644 config_examples/ /config_examples

# Copy provisioning
COPY --chmod=644 provisioning/ /provisioning

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Pin flash & sage
RUN printf "flash_attn==2.8.3\nsageattention==2.2.0\n" > /constraints.txt

# Download wheels
RUN wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.2.0/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.2.0/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Install and remove wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore \
      ./flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
      ./sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
          sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Clone install diffusion-pipe 
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe

# Install diffusion-pipe
WORKDIR /diffusion-pipe	

RUN set -eux; \
    if [ -f requirements.txt ]; then \
        sed -i -E 's/^flash-attn==[0-9.]+$/flash-attn==2.8.3/' requirements.txt; \
        echo "✅ Updated flash-attn to 2.8.3 in requirements.txt"; \
    else \
        echo "⚠️ No requirements.txt found — skipping flash-attn update"; \
    fi

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore "huggingface_hub[cli]" -r requirements.txt -c /constraints.txt

# Set working directory for runtime
WORKDIR /workspace

# Expose ports
EXPOSE 9000 6006

# Labels
LABEL org.opencontainers.image.title="Diffusion pipe Image" \
      org.opencontainers.image.description="CUDA 12.9 devel + Ubuntu 22.04 + Python + code-server + diffusion pipe" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/run-diffusion-pipe" \
      org.opencontainers.image.licenses="MIT"

# Test
RUN python -c "import torch, torchvision, torchaudio, triton; \
print(f'Torch: {torch.__version__}\\nTorchvision: {torchvision.__version__}\\nTorchaudio: {torchaudio.__version__}\\nTriton: {triton.__version__}\\nCUDA available: {torch.cuda.is_available()}\\nCUDA version: {torch.version.cuda}')"

# Start the container
CMD ["/start.sh"]