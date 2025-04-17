# Mock Environment for Member Staff Module

This directory contains everything needed to set up a local development environment for the Member Staff Flutter module, using MySQL as a mock data store and Laravel as the API layer.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/member-staff-mock-env.git
cd member-staff-mock-env
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Configure Environment

Copy the example environment file and update it with your local settings:

```bash
cp .env.example .env
```

Update the following values in `.env`:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=onesociety_dev
DB_USERNAME=root
DB_PASSWORD=secret

# For JWT token generation
JWT_SECRET=your_jwt_secret_key
```

### 4. Import Mock Data

You have two options for importing mock data:

#### Option A: Using the SQL File Directly

If you have the `mock_member_staff_seed.sql` file:

```bash
# Make the script executable
chmod +x scripts/import_sql.sh

# Run the import script
./scripts/import_sql.sh /path/to/mock_member_staff_seed.sql
```

This will copy the SQL file to the correct location and run the migrations and seeders.

#### Option B: Direct MySQL Import

You can also import the SQL file directly into MySQL:

```bash
# Make the script executable
chmod +x scripts/direct_import.sh

# Run the direct import script
./scripts/direct_import.sh /path/to/mock_member_staff_seed.sql [database_name] [username] [password]
```

#### Option C: Using Laravel Seeders

If you don't have the SQL file, you can use the built-in seeders:

```bash
php artisan migrate:fresh --seed
```

This will create all necessary tables and populate them with mock data.

### 5. Generate JWT Secret

```bash
php artisan jwt:secret
```

### 6. Start the Development Server

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`.

## Mock Data

The mock environment includes test scenarios based on the imported SQL data. The data includes:

- Members with their associated units
- Staff members with various verification statuses
- Staff schedules with time slots
- OTP records for testing verification flow

### Test Scenarios

| Test Case | Mobile | Verified | Expected UI |
|-----------|--------|----------|-------------|
| Unverified Existing Staff | 917411122233 | false | Send OTP + Verify |
| Already Verified Staff | 917422233344 | true | Block duplicate |
| New Staff | 917433344455 | — | Create new record |
| Staff with Pending OTP | 917444455566 | false | Resend OTP |
| Staff with Schedule Conflicts | 917455566677 | true | Show conflicts |

### Resetting the Database

If you need to reset the database and reload the mock data:

```bash
# Make the script executable
chmod +x scripts/reset_db.sh

# Run the reset script
./scripts/reset_db.sh
```

This script will detect whether you're using Docker or a local environment and reset the database accordingly.

## API Endpoints

The mock environment implements the following API endpoints:

- `GET /api/staff/check?mobile={mobile}` - Check if staff exists
- `POST /api/staff/send-otp` - Send OTP to mobile
- `POST /api/staff/verify-otp` - Verify OTP
- `PUT /api/staff/{id}/verify` - Verify staff identity
- `GET /api/staff/{staffId}/schedule` - Get staff schedule
- `PUT /api/staff/{staffId}/schedule` - Update staff schedule
- `POST /api/staff/{staffId}/schedule/slots` - Add time slot
- `PUT /api/staff/{staffId}/schedule/slots` - Update time slot
- `DELETE /api/staff/{staffId}/schedule/slots` - Remove time slot
- `GET /api/members/{memberId}/staff` - Get member staff
- `POST /api/member-staff/assign` - Assign staff to member
- `POST /api/member-staff/unassign` - Unassign staff from member

## Authentication

All API endpoints require authentication using a JWT token. The token should be included in the `Authorization` header:

```
Authorization: Bearer <token>
```

You can generate a test token using the following command:

```bash
php artisan generate:test-token --member-id=12 --unit-id=3 --company-id=8454
```

## Development Workflow

1. Start the Laravel development server
2. Configure your Flutter app to use the mock API
3. Use the test token for authentication
4. Develop and test your Flutter app against the mock API
5. Reset the database as needed: `php artisan migrate:fresh --seed`

## Docker Support

For convenience, a Docker Compose configuration is included:

```bash
docker-compose up -d
```

This will start MySQL, PHP, and Nginx containers.
