# Modular GitLab CI/CD Setup

This repository contains a modular GitLab CI/CD setup for Laravel applications with secure development and build practices.

## Features

1. **PHPStan** for static code analysis
2. **Laravel Pint** for code style enforcement
3. **Pest** for testing
4. **Cosign** for Docker image signing and verification
5. **SLSA** for build provenance

## Directory Structure

```
.
├── .gitlab
│   └── ci
│       ├── attest-slsa.yml
│       ├── dockerize.yml
│       ├── sign-cosign.yml
│       ├── test-pest.yml
│       ├── test-phpstan.yml
│       ├── test-pint.yml
│       └── verify-cosign.yml
├── scripts
│   ├── deploy.sh
│   └── generate-cosign-keys.sh
├── .env.testing
├── .gitlab-ci.yml
├── docker-compose.yml
├── phpstan.neon
├── pint.json
└── slsa.json.example
```

## Setup Instructions

### 1. Copy Configuration Files

Copy all the configuration files to your project:

```bash
# Create directory structure
mkdir -p .gitlab/ci scripts

# Copy CI/CD configuration files
cp -r .gitlab/ci/* your-project/.gitlab/ci/
cp scripts/* your-project/scripts/
cp .gitlab-ci.yml your-project/
cp phpstan.neon your-project/
cp pint.json your-project/
cp .env.testing your-project/
cp docker-compose.yml your-project/
```

### 2. Make Scripts Executable

```bash
chmod +x your-project/scripts/*.sh
```

### 3. Generate Cosign Keys

```bash
./scripts/generate-cosign-keys.sh
```

### 4. Configure GitLab CI/CD Variables

Set the following variables in GitLab CI/CD settings:

- `COSIGN_PRIVATE_KEY`: The content of the cosign.key file
- `COSIGN_PASSWORD`: The password you entered during key generation
- `COSIGN_PUBLIC_KEY`: The content of the cosign.pub file
- `DEPLOY_SSH_KEY`: SSH private key for deployment
- `DEPLOY_SSH_USER`: SSH username for deployment
- `DEPLOY_SSH_HOST`: SSH host for deployment
- `DEPLOY_SSH_KNOWN_HOSTS`: SSH known hosts for deployment
- `DEPLOY_PATH`: Path to the deployment directory on the target server
- `ENV_FILE_PROD`: Production environment file content
- `ENV_FILE_STAGING`: Staging environment file content

## Running Tests Locally

You can run tests locally using Docker Compose:

```bash
docker-compose up --build
```

This will:
1. Set up a MySQL database
2. Install Composer dependencies
3. Run migrations
4. Run Pest tests

## CI/CD Pipeline

The CI/CD pipeline consists of the following stages:

1. **Test**: Static analysis, code style checking, and unit/feature testing
2. **Build**: Building and pushing the Docker image
3. **Sign**: Signing the Docker image using Cosign
4. **Verify**: Verifying the Docker image signature
5. **Attest**: Creating SLSA build provenance attestation
6. **Deploy**: Deploying the application to the target environment

## Security Features

The CI/CD pipeline includes several security features:

1. **Static Analysis**: PHPStan helps identify potential bugs and issues
2. **Code Style**: Laravel Pint ensures consistent code style
3. **Testing**: Pest ensures the application works as expected
4. **Image Signing**: Cosign ensures the integrity and authenticity of Docker images
5. **Build Provenance**: SLSA provides a verifiable record of how the application was built
6. **Secure Deployment**: The deployment script includes security features for the Docker container

## Customization

You can customize the CI/CD pipeline by modifying the configuration files:

- `.gitlab-ci.yml`: Main CI/CD configuration file
- `.gitlab/ci/*.yml`: Modular CI/CD configuration files
- `scripts/*.sh`: Helper scripts

## References

- [PHPStan Documentation](https://phpstan.org/user-guide/getting-started)
- [Laravel Pint Documentation](https://laravel.com/docs/pint)
- [Pest Documentation](https://pestphp.com/docs/installation)
- [Cosign Documentation](https://github.com/sigstore/cosign)
- [SLSA Documentation](https://slsa.dev/)
