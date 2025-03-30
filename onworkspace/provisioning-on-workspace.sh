#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/examples ]]; then
	# If we don't already have /workspace/examples, move it there
	mv /examples /workspace
else
	# otherwise delete the default examples folder which is always re-created on pod start from the Docker
	rm -rf /examples
fi
