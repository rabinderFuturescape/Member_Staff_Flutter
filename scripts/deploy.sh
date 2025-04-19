#!/bin/bash
set -e

# Get the Docker image from the command line argument
DOCKER_IMAGE=$1

if [ -z "$DOCKER_IMAGE" ]; then
    echo "Error: Docker image not provided"
    echo "Usage: $0 <docker-image>"
    exit 1
fi

echo "Deploying $DOCKER_IMAGE..."

# Pull the latest Docker image
docker pull $DOCKER_IMAGE

# Stop and remove the existing container if it exists
if docker ps -a | grep -q secure-laravel-app; then
    docker stop secure-laravel-app || true
    docker rm secure-laravel-app || true
fi

# Create .env file from environment variable if it exists
if [ -n "$ENV_FILE_PROD" ]; then
    echo "$ENV_FILE_PROD" > .env
fi

# Run the new container
docker run -d \
    --name secure-laravel-app \
    --restart unless-stopped \
    -p 80:80 \
    -v $(pwd)/.env:/var/www/html/.env:ro \
    -v laravel-storage:/var/www/html/storage \
    --env RUN_MIGRATIONS=false \
    $DOCKER_IMAGE

echo "Deployment completed successfully!"
