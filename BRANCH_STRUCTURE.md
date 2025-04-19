# Branch Structure

This document outlines the branch structure for the project, with each branch focusing on a specific aspect of the CI/CD pipeline.

## Main Branch

- `feature/member-staff-implementation`: The main branch for the Member Staff implementation.

## CI/CD Pipeline Branches

- `feature/ci-cd`: Main CI/CD pipeline configuration and documentation.
- `feature/phpstan`: PHPStan static analysis configuration and CI job.
- `feature/pint`: Laravel Pint code style enforcement configuration and CI job.
- `feature/pest`: Pest testing configuration and sample tests.
- `feature/cosign`: Cosign Docker image signing configuration and scripts.
- `feature/slsa`: SLSA build provenance attestation configuration and scripts.
- `feature/dockerize`: Docker build configuration with multi-stage builds and security features.
- `feature/deploy`: Deployment configuration with security features.

## Branch Purposes

### feature/phpstan

This branch adds PHPStan static analysis to the CI/CD pipeline. PHPStan helps identify potential bugs and issues before they reach production.

Files:
- `phpstan.neon`: PHPStan configuration file.
- `.gitlab/ci/test-phpstan.yml`: GitLab CI/CD configuration for PHPStan.

### feature/pint

This branch adds Laravel Pint code style enforcement to the CI/CD pipeline. Laravel Pint helps maintain consistent code style across the codebase.

Files:
- `pint.json`: Laravel Pint configuration file.
- `.gitlab/ci/test-pint.yml`: GitLab CI/CD configuration for Laravel Pint.

### feature/pest

This branch adds Pest testing to the CI/CD pipeline. Pest is a testing framework for PHP that provides a better developer experience for writing tests.

Files:
- `tests/Pest.php`: Pest configuration file.
- `tests/Feature/StaffRatingTest.php`: Sample Pest test for the Staff Rating feature.
- `.env.testing`: Testing environment configuration.
- `.gitlab/ci/test-pest.yml`: GitLab CI/CD configuration for Pest.

### feature/cosign

This branch adds Cosign Docker image signing to the CI/CD pipeline. Cosign helps ensure the integrity and authenticity of Docker images.

Files:
- `.gitlab/ci/sign-cosign.yml`: GitLab CI/CD configuration for Cosign.
- `scripts/generate-cosign-keys.sh`: Script to generate Cosign keys.

### feature/slsa

This branch adds SLSA build provenance attestation to the CI/CD pipeline. SLSA helps provide a verifiable record of how the application was built.

Files:
- `.gitlab/ci/attest-slsa.yml`: GitLab CI/CD configuration for SLSA.
- `scripts/verify-slsa-attestation.sh`: Script to verify SLSA attestations.

### feature/dockerize

This branch adds Docker build configuration to the CI/CD pipeline. It includes multi-stage builds and security features.

Files:
- `Dockerfile`: Docker configuration with multi-stage builds and security features.
- `.gitlab/ci/dockerize.yml`: GitLab CI/CD configuration for Docker build.
- `routes/web.php.example`: Example web routes file with health check endpoint.

### feature/deploy

This branch adds deployment configuration to the CI/CD pipeline. It includes security features for deployment.

Files:
- `.gitlab/ci/deploy.yml`: GitLab CI/CD configuration for deployment.
- `scripts/deploy.sh`: Deployment script with security features.

### feature/ci-cd

This branch combines all the CI/CD pipeline features into a single configuration.

Files:
- `.gitlab-ci.yml`: Main GitLab CI/CD configuration file.
- `CI_CD_PIPELINE.md`: Documentation for the CI/CD pipeline.

## Merging Strategy

To implement the complete CI/CD pipeline, merge the branches in the following order:

1. `feature/phpstan`
2. `feature/pint`
3. `feature/pest`
4. `feature/dockerize`
5. `feature/cosign`
6. `feature/slsa`
7. `feature/deploy`
8. `feature/ci-cd`

This ensures that each feature is properly integrated into the pipeline.
