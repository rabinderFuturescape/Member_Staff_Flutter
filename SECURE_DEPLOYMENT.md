# Secure Laravel Deployment with ionCube

This document outlines a secure CI/CD pipeline for deploying Laravel applications with ionCube encoding.

## Overview

The deployment process includes:

1. Building the Laravel application
2. Encoding PHP files using ionCube
3. Dockerizing the application
4. Deploying to production

## Project Structure

```
/project-root
├── app/                  # Laravel application code (will be encoded)
├── bootstrap/            # Laravel bootstrap files
├── config/               # Laravel configuration (will be encoded)
├── database/             # Laravel database files
│   ├── factories/        # Factories (will be encoded)
│   ├── migrations/       # Migrations (not encoded)
│   └── seeders/          # Seeders (will be encoded)
├── docker/               # Docker configuration files
│   ├── nginx.conf        # Nginx configuration
│   ├── php.ini           # PHP configuration
│   ├── start.sh          # Container startup script
│   ├── supervisord.conf  # Supervisor configuration
│   └── www.conf          # PHP-FPM configuration
├── public/               # Public assets (not encoded)
├── resources/            # Laravel resources (not encoded)
├── routes/               # Laravel routes (will be encoded)
├── scripts/              # Deployment scripts
│   └── deploy.sh         # Script to deploy the application
├── storage/              # Laravel storage (not encoded)
├── .env.example          # Example environment file
├── .gitlab-ci.yml        # GitLab CI/CD configuration
├── Dockerfile            # Docker configuration
├── license.lic           # ionCube license file
└── README.md             # Project README
```

## GitLab CI/CD Variables

Set the following variables in GitLab CI/CD settings:

- `LICENSE_FILE`: Path to the ionCube license file (default: license.lic)
- `EXPIRY_DATE`: Expiry date for encoded files (default: 2025-12-31)
- `DEPLOY_SSH_KEY`: SSH private key for deployment
- `DEPLOY_SSH_USER`: SSH username for deployment
- `DEPLOY_SSH_HOST`: SSH host for deployment
- `DEPLOY_SSH_KNOWN_HOSTS`: SSH known hosts for deployment
- `ENV_FILE_PROD`: Production environment file content

## Security Best Practices

This deployment implements the following security best practices:

1. **Code Protection**:
   - Only deploy ionCube-encoded files
   - Encode only necessary files (app/, routes/, etc.)

2. **Environment**:
   - Inject .env at runtime using Docker volumes
   - Store sensitive data in GitLab CI/CD variables

3. **Container**:
   - Use non-root user (www)
   - Implement proper file permissions
   - Configure PHP with secure settings

4. **PHP Configuration**:
   - Disable dangerous functions (system, exec, etc.)
   - Enable OPcache for performance
   - Set secure PHP settings

5. **Laravel**:
   - Set APP_DEBUG=false in production
   - Set APP_ENV=production
   - Configure proper error logging

## Deployment

The deployment process is automated through GitLab CI/CD. When you push to the main branch, the pipeline will:

1. Build the Laravel application
2. Encode PHP files using ionCube
3. Build a Docker image
4. Deploy to production

## Local Development

For local development, you can use the following commands:

```bash
# Build the Docker image
docker build -t secure-laravel-app .

# Run the Docker container
docker run -d --name secure-laravel-app -p 80:80 -v $(pwd)/.env:/var/www/html/.env:ro secure-laravel-app
```

## ionCube Encoding Strategy

The encoding strategy focuses on protecting your application logic while maintaining compatibility and performance:

### Files to Encode:
- `app/` - Application logic
- `routes/` - Route definitions
- `database/seeders/` - Database seeders
- `database/factories/` - Model factories
- `config/` - Configuration files

### Files NOT to Encode:
- `vendor/` - Composer dependencies
- `public/` - Public assets
- `storage/` - Storage files
- `bootstrap/` - Bootstrap files
- `database/migrations/` - Database migrations

### Encoding Command:
```bash
./ioncube_encoder.sh \
  -o encoded-src/ \
  app/ \
  routes/ \
  database/ \
  config/ \
  --with-license=license.lic \
  --expire "2025-12-31" \
  --obfuscate
```

## Alternative Approach: Secure PHP Deployment Without ionCube

If you prefer not to use ionCube, you can implement a secure PHP deployment using:

1. Multi-stage Docker builds
2. OPcache preloading
3. File permissions hardening
4. Non-root execution
5. Read-only filesystem

The `.gitlab-ci.yml` file for this approach would be:

```yaml
stages:
  - build
  - dockerize
  - deploy

variables:
  DOCKER_IMAGE: registry.example.com/secure-php-app
  DOCKER_TLS_CERTDIR: ""

# 🧱 Stage 1 – Composer Build & Artifact Packaging
build_php:
  image: composer:2
  stage: build
  script:
    - composer install --no-dev --optimize-autoloader
    - mkdir -p build-artifacts
    - cp -r app bootstrap config public routes storage vendor .env build-artifacts/
  artifacts:
    paths:
      - build-artifacts/

# 🐳 Stage 2 – Build Hardened Docker Image
dockerize:
  image: docker:24
  stage: dockerize
  services:
    - docker:dind
  script:
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA

# 🚀 Stage 3 – Deployment (SSH, Kubernetes, ECS, etc.)
deploy:
  stage: deploy
  script:
    - echo "Deploying image $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA to production..."
    - ./scripts/deploy.sh $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA
```

And the Dockerfile would be:

```dockerfile
# Stage 1 – Build phase
FROM composer:2 AS builder

WORKDIR /app

COPY . /app
RUN composer install --no-dev --optimize-autoloader

# Stage 2 – Runtime phase
FROM php:8.2-fpm-alpine

# Install required extensions and runtime dependencies
RUN apk --no-cache add nginx bash curl tzdata \
  && docker-php-ext-install pdo pdo_mysql opcache

# Copy only production artifacts from builder
COPY --from=builder /app /var/www/html

# Set permissions (non-root user)
RUN addgroup -g 1000 www && \
    adduser -G www -g www -s /bin/sh -D www && \
    chown -R www:www /var/www/html

USER www

# Set working directory
WORKDIR /var/www/html

# Configure PHP
COPY ./docker/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Optionally include Nginx
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["php-fpm"]
```
