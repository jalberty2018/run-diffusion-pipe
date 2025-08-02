# Base image
FROM ls250824/pytorch-cuda-ubuntu-develop:21072025 AS base

# Set working directory
WORKDIR /

# Copy start script
COPY --chmod=755 start.sh onworkspace/diffusion-pipe-on-workspace.sh onworkspace/examples-on-workspace.sh onworkspace/provisioning-on-workspace.sh onworkspace/readme-on-workspace.sh   /

# Copy supporting files
COPY --chmod=644 documentation/README_runpod.md /

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Copy Scripts directory
COPY --chmod=644 examples /examples
COPY --chmod=644 provisioning /provisioning

# Download the wheel for flash_attn
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.0.0/flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl

# Install wheel
RUN pip3 install --no-cache-dir -U "huggingface_hub[cli]" \
    flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl \
    rm -f flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl

# Clone and install diffusion-pipe
RUN git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe && \
    cd diffusion-pipe && \
    python -m pip install --no-cache-dir -U "huggingface_hub[cli]" -r requirements.txt

# Set working directory for runtime
WORKDIR /workspace

# Expose ports
EXPOSE 9000 6006

# Start the container
CMD ["/start.sh"]