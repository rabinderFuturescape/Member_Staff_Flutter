#!/bin/bash

# Check if the SQL file path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_sql_file>"
  exit 1
fi

SQL_FILE=$1
TARGET_DIR="database/seeders/sql"

# Check if the SQL file exists
if [ ! -f "$SQL_FILE" ]; then
  echo "Error: SQL file not found: $SQL_FILE"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the SQL file to the target directory
cp "$SQL_FILE" "$TARGET_DIR/mock_member_staff_seed.sql"

echo "SQL file copied to $TARGET_DIR/mock_member_staff_seed.sql"
echo "Running database migration and seeding..."

# Run the migration and seeding
php artisan migrate:fresh --seed

echo "Done! The database has been populated with the mock data."
