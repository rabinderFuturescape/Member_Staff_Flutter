# Mock Data Development Guide for Member Staff Module

This guide explains how to use the mock environment for developing the Member Staff Flutter module.

## Overview

The mock environment provides:

1. A Laravel API that mimics the production API
2. A MySQL database with realistic mock data
3. JWT authentication with member context
4. Docker support for easy setup

## Setup Instructions

### Option 1: Local Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/member-staff-mock-env.git
   cd member-staff-mock-env
   ```

2. Install dependencies:
   ```bash
   composer install
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   php artisan jwt:secret
   ```

4. Set up the database:
   ```bash
   php artisan migrate:fresh --seed
   ```

5. Start the development server:
   ```bash
   php artisan serve
   ```

### Option 2: Docker Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/member-staff-mock-env.git
   cd member-staff-mock-env
   ```

2. Configure environment:
   ```bash
   cp .env.example .env
   ```

3. Start Docker containers:
   ```bash
   docker-compose up -d
   ```

4. Install dependencies and set up the database:
   ```bash
   docker-compose exec app composer install
   docker-compose exec app php artisan key:generate
   docker-compose exec app php artisan jwt:secret
   docker-compose exec app php artisan migrate:fresh --seed
   ```

## Generating Test Tokens

To generate a JWT token for testing:

```bash
php artisan generate:test-token --member-id=<member_id> --unit-id=<unit_id> --company-id=<company_id>
```

Or use the API endpoint:

```bash
curl -X POST http://localhost:8000/api/auth/generate-test-token \
  -H "Content-Type: application/json" \
  -d '{"member_id":"<member_id>","unit_id":"<unit_id>","company_id":"<company_id>"}'
```

## Mock Data Scenarios

The mock environment includes the following test scenarios:

| Test Case | Mobile | Verified | Expected UI |
|-----------|--------|----------|-------------|
| Unverified Existing Staff | 917411122233 | false | Send OTP + Verify |
| Already Verified Staff | 917422233344 | true | Block duplicate |
| New Staff | 917433344455 | — | Create new record |
| Staff with Pending OTP | 917444455566 | false | Resend OTP |
| Staff with Schedule Conflicts | 917455566677 | true | Show conflicts |

## Flutter Integration

To integrate your Flutter app with the mock API:

1. Configure your API client to use the mock API URL:
   ```dart
   final apiClient = ApiClient(baseUrl: 'http://localhost:8000/api');
   ```

2. Set the JWT token in your auth service:
   ```dart
   await TokenManager.saveAuthToken(token);
   ```

3. Make API requests as you would in production:
   ```dart
   final response = await apiClient.get('staff/check?mobile=917411122233');
   ```

## Development Workflow

1. Start the Laravel development server
2. Generate a test token
3. Configure your Flutter app to use the mock API
4. Develop and test your Flutter app against the mock API
5. Reset the database as needed: `php artisan migrate:fresh --seed`

## Refreshing Mock Data

To reset the database and reload mock data:

```bash
php artisan migrate:fresh --seed
```

This is useful when you want to start with a clean slate or if you've made changes to the seeders.

## Adding Custom Test Scenarios

To add custom test scenarios:

1. Edit the `database/seeders/MockStaffSeeder.php` file
2. Add your custom data
3. Run `php artisan migrate:fresh --seed` to reload the data

## Troubleshooting

### API Returns 401 Unauthorized

- Make sure you're including the JWT token in the Authorization header
- Check if the token has expired
- Generate a new token using the command or API endpoint

### Database Connection Issues

- Check your `.env` file for correct database credentials
- Make sure the MySQL service is running
- If using Docker, check if the containers are running with `docker-compose ps`

### CORS Issues

If you're experiencing CORS issues when calling the API from Flutter:

1. Edit `config/cors.php` to allow your Flutter app's origin
2. Restart the Laravel server

## API Documentation

For detailed API documentation, refer to the OpenAPI specification file at `api/member_staff_api_spec.yaml`.
