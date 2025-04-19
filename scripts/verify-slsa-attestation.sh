#!/bin/bash
set -e

# Check if cosign is installed
if ! command -v cosign &> /dev/null; then
    echo "Error: cosign is not installed. Please install it first."
    echo "You can download it from: https://github.com/sigstore/cosign/releases"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

# Get the Docker image from the command line argument
DOCKER_IMAGE=$1

if [ -z "$DOCKER_IMAGE" ]; then
    echo "Error: Docker image not provided"
    echo "Usage: $0 <docker-image>"
    exit 1
fi

echo "Verifying SLSA attestation for $DOCKER_IMAGE..."

# Verify the attestation
cosign verify-attestation --key cosign.pub --type slsaprovenance $DOCKER_IMAGE

# Extract and display the attestation
cosign verify-attestation --key cosign.pub --type slsaprovenance $DOCKER_IMAGE | jq -r '.payload' | base64 -d | jq .

echo "Attestation verification completed!"
