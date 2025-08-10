#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/configs ]]; then
	# If we don't already have /workspace/configs, move it there
	mv /configs /workspace
	# Set permissions right for directory
    chmod -R 777 /workspace/configs
else
	# otherwise delete the default provisioning folder which is always re-created on pod start from the Docker
	rm -rf /configs
fi

# Linking
ln -s /workspace/configs /configs