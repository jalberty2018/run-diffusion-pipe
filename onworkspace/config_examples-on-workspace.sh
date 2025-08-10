#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/config_examples ]]; then
	# If we don't already have /workspace/config_examples, move it there
	mv /config_examples /workspace
	# Set permissions right for directory
    chmod -R 777 /workspace/config_examples
else
	# otherwise delete the default provisioning folder which is always re-created on pod start from the Docker
	rm -rf /config_examples
fi

# Linking
ln -s /workspace/config_examples /config_examples