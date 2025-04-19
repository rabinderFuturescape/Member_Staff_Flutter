#!/bin/bash
set -e

# Check if cosign is installed
if ! command -v cosign &> /dev/null; then
    echo "Error: cosign is not installed. Please install it first."
    echo "You can download it from: https://github.com/sigstore/cosign/releases"
    exit 1
fi

# Generate key pair
echo "Generating Cosign key pair..."
cosign generate-key-pair

# Instructions for GitLab CI/CD variables
echo ""
echo "Please add the following variables to your GitLab CI/CD settings:"
echo "1. COSIGN_PRIVATE_KEY: The content of the cosign.key file"
echo "2. COSIGN_PASSWORD: The password you entered during key generation"
echo "3. COSIGN_PUBLIC_KEY: The content of the cosign.pub file"
echo ""
echo "Keep the private key secure and do not commit it to the repository!"
