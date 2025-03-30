#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/diffusion-pipe ]]; then
	# If we don't already have /workspace/diffusion-pipe, move it there
	mv /diffusion-pipe /workspace
else
	# otherwise delete the default diffusion-pipe folder which is always re-created on pod start from the Docker
	rm -rf /diffusion-pipe
fi

# Then link folder to /workspace so it's available in that familiar location as well
ln -s /workspace/diffusion-pipe /diffusion-pipe
