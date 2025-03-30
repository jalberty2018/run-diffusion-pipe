#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/provisioning ]]; then
	# If we don't already have /workspace/provisioning, move it there
	mv /provisioning /workspace
else
	# otherwise delete the default provisioning folder which is always re-created on pod start from the Docker
	rm -rf /provisioning
fi
