# Using the SQL Seed File for Mock Data

This guide explains how to use the provided SQL seed file to populate your mock environment with realistic test data.

## Download the SQL Seed File

The SQL seed file `mock_member_staff_seed.sql` is available for download from the provided link. This file contains all the necessary mock data for testing the Member Staff module.

## What's in the SQL Seed File?

The `mock_member_staff_seed.sql` file contains pre-populated data for:

- **members**: Member records with their details
- **units**: Unit records associated with members
- **staff**: Staff records with various verification statuses
- **staff_schedules**: Time slot schedules for staff members

This data is carefully designed to provide realistic test scenarios for the Member Staff module. The SQL file ensures consistent test data across all development environments, making it easier to reproduce and fix issues.

## Prerequisites

Before importing the SQL file, ensure that:

1. You have a MySQL database set up
2. The following tables exist (or will be created by migrations):
   - members
   - units
   - staff
   - staff_schedules
3. You have the necessary permissions to import data into the database

## Import Options

### Option 1: Using the Import Script

The easiest way to import the SQL file is to use the provided import script:

```bash
# Make the script executable
chmod +x scripts/import_sql.sh

# Run the import script
./scripts/import_sql.sh /path/to/mock_member_staff_seed.sql
```

This script will:
1. Copy the SQL file to the correct location (`database/seeders/sql/`)
2. Run the Laravel migrations to create the tables
3. Import the SQL data using the Laravel seeder

### Option 2: Direct MySQL Import

If you prefer to import the SQL file directly into MySQL:

```bash
# Make the script executable
chmod +x scripts/direct_import.sh

# Run the direct import script
./scripts/direct_import.sh /path/to/mock_member_staff_seed.sql [database_name] [username] [password]
```

Default values if not provided:
- database_name: onesociety_dev
- username: root
- password: secret

### Option 3: Manual Import

You can also manually import the SQL file:

1. Copy the SQL file to `database/seeders/sql/mock_member_staff_seed.sql`
2. Run the Laravel migrations and seeders:
   ```bash
   php artisan migrate:fresh --seed
   ```

Or import directly into MySQL:

```bash
mysql -u root -p onesociety_dev < /path/to/mock_member_staff_seed.sql
```

## Docker Support

If you're using Docker, you can import the SQL file into the Docker container:

```bash
# Copy the SQL file to the container
docker cp /path/to/mock_member_staff_seed.sql onesociety-db:/tmp/

# Import the SQL file
docker-compose exec db mysql -u root -p onesociety_dev < /tmp/mock_member_staff_seed.sql
```

Or use the provided script which handles Docker detection:

```bash
./scripts/reset_db.sh
```

## Verifying the Import

To verify that the data was imported correctly:

```bash
# Using Laravel Tinker
php artisan tinker
>>> DB::table('members')->count();
>>> DB::table('staff')->count();
>>> DB::table('units')->count();
>>> DB::table('staff_schedules')->count();
```

Or using MySQL directly:

```bash
mysql -u root -p
mysql> USE onesociety_dev;
mysql> SELECT COUNT(*) FROM members;
mysql> SELECT COUNT(*) FROM staff;
mysql> SELECT COUNT(*) FROM units;
mysql> SELECT COUNT(*) FROM staff_schedules;
```

## Test Scenarios

The imported data includes several test scenarios:

| Test Case | Mobile | Verified | Expected UI |
|-----------|--------|----------|-------------|
| Unverified Existing Staff | 917411122233 | false | Send OTP + Verify |
| Already Verified Staff | 917422233344 | true | Block duplicate |
| New Staff | 917433344455 | — | Create new record |
| Staff with Pending OTP | 917444455566 | false | Resend OTP |
| Staff with Schedule Conflicts | 917455566677 | true | Show conflicts |

### Using the Test Scenarios

These test scenarios are designed to cover the main flows in the Member Staff module:

1. **OTP Flow Testing**: Use the unverified staff and pending OTP scenarios to test the complete OTP verification flow
2. **Staff Lookup**: Test searching for staff by mobile number with various verification statuses
3. **Schedule Rendering**: Use the staff with schedule conflicts to test the calendar view and conflict detection

All these scenarios can be used in both Laravel backend testing and Flutter frontend development.

## Resetting the Database

If you need to reset the database and reload the mock data:

```bash
./scripts/reset_db.sh
```

This script will detect whether you're using Docker or a local environment and reset the database accordingly.

## Integration with Laravel and Flutter

Once the mock data is imported, you can use it for both Laravel API development and Flutter frontend development:

### Laravel Development

- Use the mock data to test API endpoints
- Implement the verification flow using the test scenarios
- Test schedule management with the provided time slots

### Flutter Development

- Connect your Flutter app to the Laravel API
- Test the OTP verification flow using the provided mobile numbers
- Implement the staff schedule calendar view with conflict detection
- Test the complete user journey from staff lookup to verification

This approach ensures that both backend and frontend development can proceed in parallel with consistent test data.
