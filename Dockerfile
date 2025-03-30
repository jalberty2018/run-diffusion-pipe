# Base image
FROM ls250824/pytorch-cuda-ubuntu-develop:08122024 AS base

# Set working directory
WORKDIR /

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Copy start script
COPY --chmod=755 start.sh /

# Copy supporting files
COPY --chmod=644 documentation/README.md /
COPY --chmod=755 onworkspace/diffusion-pipe-on-workspace.sh /
COPY --chmod=755 onworkspace/examples-on-workspace.sh /
COPY --chmod=755 onworkspace/provisioning-on-workspace.sh /
COPY --chmod=755 onworkspace/readme-on-workspace.sh /

# Copy Scripts directory
COPY --chmod=644 examples /examples
COPY --chmod=644 provisioning /provisioning

# Clone and install diffusion-pipe
RUN git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe && \
    cd diffusion-pipe && \
    python -m pip install --no-cache-dir -r requirements.txt

# Set working directory for runtime
WORKDIR /workspace

# Expose ports
EXPOSE 9000 6006

# Start the container
CMD ["/start.sh"]