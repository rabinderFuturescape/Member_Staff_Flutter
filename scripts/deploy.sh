#!/bin/bash
set -e

# Get the Docker image and environment from the command line arguments
DOCKER_IMAGE=$1
ENVIRONMENT=${2:-production}

if [ -z "$DOCKER_IMAGE" ]; then
    echo "Error: Docker image not provided"
    echo "Usage: $0 <docker-image> [environment]"
    exit 1
fi

echo "Deploying $DOCKER_IMAGE to $ENVIRONMENT environment..."

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
    source .env.$ENVIRONMENT
fi

# Verify Docker image signature if cosign is available
if command -v cosign &> /dev/null; then
    echo "Verifying Docker image signature..."
    if [ -f "cosign.pub" ]; then
        cosign verify --key cosign.pub $DOCKER_IMAGE || {
            echo "Error: Image signature verification failed"
            exit 1
        }
    else
        echo "Warning: cosign.pub not found, skipping signature verification"
    fi
fi

# Pull the latest Docker image
docker pull $DOCKER_IMAGE

# Define container name based on environment
CONTAINER_NAME="secure-laravel-app-$ENVIRONMENT"

# Stop and remove the existing container if it exists
if docker ps -a | grep -q $CONTAINER_NAME; then
    echo "Stopping and removing existing container..."
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
fi

# Create .env file from environment variable if it exists
ENV_VAR_NAME="ENV_FILE_${ENVIRONMENT^^}"
if [ -n "${!ENV_VAR_NAME}" ]; then
    echo "Creating .env file from environment variable..."
    echo "${!ENV_VAR_NAME}" > .env
fi

# Set up port mapping based on environment
if [ "$ENVIRONMENT" = "production" ]; then
    PORT_MAPPING="80:80"
else
    PORT_MAPPING="8080:80"
fi

# Run the new container with security options
echo "Starting new container..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $PORT_MAPPING \
    -v $(pwd)/.env:/var/www/html/.env:ro \
    -v ${CONTAINER_NAME}-storage:/var/www/html/storage \
    --env RUN_MIGRATIONS=${RUN_MIGRATIONS:-false} \
    --env APP_ENV=$ENVIRONMENT \
    --security-opt no-new-privileges:true \
    --cap-drop=ALL \
    --cap-add=NET_BIND_SERVICE \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid \
    $DOCKER_IMAGE

# Wait for container to be healthy
echo "Waiting for container to be healthy..."
for i in {1..30}; do
    if [ "$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null)" = "healthy" ]; then
        echo "Container is healthy!"
        break
    fi
    echo "Waiting for container to be healthy... ($i/30)"
    sleep 2
done

# Verify container is running
if [ "$(docker inspect --format='{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)" != "running" ]; then
    echo "Error: Container is not running"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo "Deployment to $ENVIRONMENT completed successfully!"
