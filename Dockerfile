# Base image
FROM ls250824/pytorch-cuda-ubuntu-develop:21072025 AS base

# Set working directory
WORKDIR /

# Copy start script
COPY --chmod=755 start.sh onworkspace/diffusion-pipe-on-workspace.sh onworkspace/config_examples-on-workspace.sh onworkspace/provisioning-on-workspace.sh onworkspace/readme-on-workspace.sh /

# Copy supporting files
COPY --chmod=664 /documentation/README_runpod.md /README.md

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Copy config_examples
COPY --chmod=644 config_examples/ /config_examples

# Copy provisioning with appropriate permissions
COPY --chmod=644 provisioning/ /provisioning

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