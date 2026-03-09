# syntax=docker/dockerfile:1.7
FROM ls250824/pytorch-cuda-ubuntu-develop:08112025

# Set working directory
WORKDIR /

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Pin
COPY constraints.txt /constraints.txt

# Download wheels
RUN wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Install and remove wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
      ./flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
      ./sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
      "huggingface_hub" && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
          sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Clone install diffusion-pipe 
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe

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
LABEL org.opencontainers.image.title="Diffusion pipe Image" \
      org.opencontainers.image.description="Pytorch 2.9 CUDA 12.8 devel + Ubuntu 22.04 + Python + code-server + diffusion pipe" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/run-diffusion-pipe" \
      org.opencontainers.image.licenses="MIT"

# Test
RUN python -c "import torch, torchvision, torchaudio, triton; \
print(f'Torch: {torch.__version__}\\nTorchvision: {torchvision.__version__}\\nTorchaudio: {torchaudio.__version__}\\nTriton: {triton.__version__}\\nCUDA available: {torch.cuda.is_available()}\\nCUDA version: {torch.version.cuda}')"

# Start the container
CMD ["/start.sh"]