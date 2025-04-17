# Utility Scripts

This directory contains utility scripts for managing the mock environment.

## Available Scripts

### 1. import_sql.sh

Imports a SQL file into the Laravel application.

```bash
# Make the script executable
chmod +x import_sql.sh

# Usage
./import_sql.sh /path/to/mock_member_staff_seed.sql
```

This script:
1. Copies the SQL file to `database/seeders/sql/mock_member_staff_seed.sql`
2. Runs `php artisan migrate:fresh --seed` to create tables and import the data

### 2. direct_import.sh

Imports a SQL file directly into MySQL.

```bash
# Make the script executable
chmod +x direct_import.sh

# Usage
./direct_import.sh /path/to/mock_member_staff_seed.sql [database_name] [username] [password]
```

Default values if not provided:
- database_name: onesociety_dev
- username: root
- password: secret

### 3. reset_db.sh

Resets the database and reloads the mock data.

```bash
# Make the script executable
chmod +x reset_db.sh

# Usage
./reset_db.sh
```

This script:
1. Detects whether you're using Docker or a local environment
2. Runs `php artisan migrate:fresh` to reset the database
3. Imports the SQL file if it exists, or runs the seeders if not

## Docker Support

All scripts are designed to work with both local and Docker environments. The `reset_db.sh` script automatically detects whether you're using Docker and adjusts the commands accordingly.
