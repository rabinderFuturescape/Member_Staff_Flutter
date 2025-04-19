# Secure CI/CD Pipeline for Laravel Application

This document outlines the secure CI/CD pipeline implemented for the Laravel application, including static analysis, code style enforcement, testing, Docker image signing, and SLSA build provenance.

## Pipeline Overview

The CI/CD pipeline consists of the following stages:

1. **Test**: Static analysis, code style checking, and unit/feature testing
2. **Build**: Building the Laravel application
3. **Encode**: Encoding PHP files using ionCube
4. **Dockerize**: Building and pushing the Docker image
5. **Sign**: Signing the Docker image using Cosign
6. **Verify**: Verifying the Docker image signature
7. **Attest**: Creating SLSA build provenance attestation
8. **Deploy**: Deploying the application to the target environment

## Security Features

### 1. Static Analysis with PHPStan

PHPStan is used to perform static code analysis, which helps identify potential bugs and issues before they reach production.

```yaml
phpstan:
  image: php:8.2-cli
  stage: test
  before_script:
    - apt-get update && apt-get install -y git unzip curl
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install
  script:
    - ./vendor/bin/phpstan analyse
```

Configuration file: `phpstan.neon`

### 2. Code Style with Laravel Pint

Laravel Pint is used to enforce consistent code style across the codebase.

```yaml
pint:
  image: php:8.2-cli
  stage: test
  before_script:
    - apt-get update && apt-get install -y git unzip curl
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install
  script:
    - ./vendor/bin/pint --test
```

Configuration file: `pint.json`

### 3. Testing with Pest

Pest is used for unit and feature testing to ensure the application works as expected.

```yaml
pest:
  image: php:8.2-cli
  stage: test
  services:
    - mysql:5.7
  variables:
    DB_HOST: mysql
    DB_DATABASE: test_db
    DB_USERNAME: root
    DB_PASSWORD: secret
  before_script:
    - apt-get update && apt-get install -y git unzip curl libpng-dev libzip-dev zip
    - docker-php-ext-install pdo_mysql gd zip
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install
    - cp .env.testing .env
    - php artisan key:generate
    - php artisan migrate --force
  script:
    - ./vendor/bin/pest --coverage --min=80
```

### 4. Docker Image Signing with Cosign

Cosign is used to sign and verify Docker images, ensuring the integrity and authenticity of the images.

```yaml
cosign-sign:
  image: golang:1.21
  stage: sign
  before_script:
    - apt-get update && apt-get install -y curl
    - curl -sSLo cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
    - chmod +x cosign && mv cosign /usr/local/bin/
  script:
    - echo "$COSIGN_PRIVATE_KEY" > cosign.key
    - cosign sign --key cosign.key $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA
```

### 5. SLSA Build Provenance

SLSA (Supply-chain Levels for Software Artifacts) build provenance is used to provide a verifiable record of how the application was built.

```yaml
slsa-provenance:
  image: golang:1.21
  stage: attest
  before_script:
    - apt-get update && apt-get install -y curl jq
    - curl -sSLo cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
    - chmod +x cosign && mv cosign /usr/local/bin/
  script:
    # Create SLSA provenance document
    - |
      cat > slsa.json << EOF
      {
        "_type": "https://in-toto.io/Statement/v0.1",
        "predicateType": "https://slsa.dev/provenance/v0.2",
        "subject": [
          {
            "name": "$DOCKER_IMAGE",
            "digest": {
              "sha256": "$(docker inspect $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA --format='{{index .RepoDigests 0}}' | cut -d '@' -f 2 | cut -d ':' -f 2)"
            }
          }
        ],
        "predicate": {
          "builder": {
            "id": "https://gitlab.com/$CI_PROJECT_PATH/pipelines/$CI_PIPELINE_ID"
          },
          "buildType": "https://gitlab.com/gitlab-ci",
          "invocation": {
            "configSource": {
              "uri": "git+https://gitlab.com/$CI_PROJECT_PATH.git",
              "digest": {
                "sha1": "$CI_COMMIT_SHA"
              },
              "entryPoint": ".gitlab-ci.yml"
            },
            "parameters": {},
            "environment": {
              "gitlabPipeline": "$CI_PIPELINE_ID",
              "gitlabRunner": "$CI_RUNNER_ID",
              "gitlabProject": "$CI_PROJECT_PATH"
            }
          },
          "metadata": {
            "buildStartedOn": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
            "buildFinishedOn": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
            "completeness": {
              "parameters": true,
              "environment": true,
              "materials": true
            },
            "reproducible": false
          },
          "materials": [
            {
              "uri": "git+https://gitlab.com/$CI_PROJECT_PATH.git",
              "digest": {
                "sha1": "$CI_COMMIT_SHA"
              }
            }
          ]
        }
      }
      EOF
    - echo "$COSIGN_PRIVATE_KEY" > cosign.key
    - cosign attest --predicate slsa.json --type slsaprovenance --key cosign.key $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA
```

## Docker Security Features

The Docker image is built with security in mind:

1. **Multi-stage builds**: Separate build and runtime stages to minimize the final image size
2. **Non-root user**: The application runs as a non-root user (www)
3. **Read-only filesystem**: The filesystem is mounted as read-only to prevent modifications
4. **Dropped capabilities**: All capabilities are dropped except those required for the application
5. **No new privileges**: The container is prevented from gaining new privileges
6. **Health check**: A health check is included to ensure the application is running correctly

## Deployment Security Features

The deployment process includes several security features:

1. **Image verification**: The Docker image signature is verified before deployment
2. **Environment-specific configuration**: Different configurations for different environments
3. **Secure environment variables**: Sensitive information is stored in GitLab CI/CD variables
4. **SSH key authentication**: SSH key authentication is used for deployment
5. **Container security options**: Security options are applied to the container during deployment

## GitLab CI/CD Variables

The following variables should be set in GitLab CI/CD settings:

- `LICENSE_FILE`: Path to the ionCube license file
- `EXPIRY_DATE`: Expiry date for encoded files
- `COSIGN_PRIVATE_KEY`: Cosign private key for signing Docker images
- `COSIGN_PASSWORD`: Password for the Cosign private key
- `COSIGN_PUBLIC_KEY`: Cosign public key for verifying Docker images
- `DEPLOY_SSH_KEY`: SSH private key for deployment
- `DEPLOY_SSH_USER`: SSH username for deployment
- `DEPLOY_SSH_HOST`: SSH host for deployment
- `DEPLOY_SSH_KNOWN_HOSTS`: SSH known hosts for deployment
- `DEPLOY_ENVIRONMENT`: Deployment environment (e.g., production, staging)
- `DEPLOY_PATH`: Path to the deployment directory on the target server
- `ENV_FILE_PROD`: Production environment file content
- `ENV_FILE_STAGING`: Staging environment file content

## Branch Structure

The CI/CD pipeline is organized into separate branches for each feature:

1. `feature/phpstan`: PHPStan configuration and CI job
2. `feature/pint`: Laravel Pint configuration and CI job
3. `feature/pest`: Pest testing configuration and sample tests
4. `feature/cosign`: Cosign configuration for Docker image signing
5. `feature/slsa`: SLSA build provenance attestation
6. `feature/dockerize`: Docker build configuration
7. `feature/deploy`: Deployment configuration
8. `feature/ci-cd`: Main CI/CD pipeline configuration

## Setup Instructions

### 1. Generate Cosign Keys

```bash
./scripts/generate-cosign-keys.sh
```

Add the generated keys to GitLab CI/CD variables.

### 2. Configure GitLab CI/CD Variables

Set the required variables in GitLab CI/CD settings.

### 3. Create Required Branches

Create the required branches for each feature.

### 4. Merge Branches

Merge the feature branches into the main branch.

## Verification

### 1. Verify Docker Image Signature

```bash
./scripts/verify-slsa-attestation.sh registry.example.com/secure-laravel-app:latest
```

### 2. Verify SLSA Attestation

```bash
cosign verify-attestation --key cosign.pub --type slsaprovenance registry.example.com/secure-laravel-app:latest
```

## Conclusion

This secure CI/CD pipeline provides a comprehensive approach to securing the Laravel application, from static analysis to deployment. By implementing these security features, the application is protected against a wide range of threats and vulnerabilities.
