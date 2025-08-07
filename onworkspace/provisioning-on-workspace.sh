#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/provisioning ]]; then
	# If we don't already have /workspace/provisioning, move it there
	mv /provisioning /workspace
	# Set permissions right for directory
    chmod -R 777 /workspace/provisioning
else
	# otherwise delete the default examples folder which is always re-created on pod start from the Docker
	rm -rf /provisioning
fi

# Linking
ln -s /workspace/provisioning /provisioning