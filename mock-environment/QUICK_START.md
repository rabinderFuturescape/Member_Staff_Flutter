# Quick Start Guide

This guide provides a quick way to get started with the Member Staff mock environment.

## 1. Download the SQL Seed File

First, download the SQL seed file from the provided link:
```
🔗 mock_member_staff_seed.sql
```

## 2. Set Up the Environment

Clone the repository and install dependencies:

```bash
# Clone the repository
git clone https://github.com/your-org/member-staff-mock-env.git
cd member-staff-mock-env

# Install dependencies
composer install

# Configure environment
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
```

## 3. Import the Mock Data

Use the provided script to import the SQL file:

```bash
# Make the script executable
chmod +x scripts/import_sql.sh

# Import the SQL file
./scripts/import_sql.sh /path/to/mock_member_staff_seed.sql
```

## 4. Start the Development Server

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`.

## 5. Generate a Test Token

Generate a JWT token for testing:

```bash
php artisan generate:test-token
```

## 6. Test the API

You can now test the API using the provided mobile numbers:

| Test Case | Mobile |
|-----------|--------|
| Unverified Existing Staff | 917411122233 |
| Already Verified Staff | 917422233344 |
| New Staff | 917433344455 |
| Staff with Pending OTP | 917444455566 |
| Staff with Schedule Conflicts | 917455566677 |

Example API call:

```bash
curl -X GET "http://localhost:8000/api/staff/check?mobile=917411122233" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 7. Connect Your Flutter App

Update your Flutter app to use the mock API:

```dart
// lib/src/core/network/api_client.dart
class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Rest of the class...
}
```

Set the JWT token in your app:

```dart
// After generating the token
await TokenManager.saveAuthToken(token);
```

## 8. Reset the Database (If Needed)

If you need to reset the database and reload the mock data:

```bash
./scripts/reset_db.sh
```

## Next Steps

For more detailed information, refer to:

- [Using SQL Seed](USING_SQL_SEED.md) - Detailed guide on using the SQL seed file
- [Mock Data Structure](MOCK_DATA_STRUCTURE.md) - Information about the mock data structure
- [Flutter Integration](FLUTTER_INTEGRATION.md) - Guide on integrating with Flutter
- [Test Scenarios](TEST_SCENARIOS.md) - Detailed test scenarios

Happy coding!
