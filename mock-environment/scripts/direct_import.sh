#!/bin/bash

# Check if the SQL file path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_sql_file> [database_name] [username] [password]"
  exit 1
fi

SQL_FILE=$1
DB_NAME=${2:-onesociety_dev}
DB_USER=${3:-root}
DB_PASS=${4:-secret}

# Check if the SQL file exists
if [ ! -f "$SQL_FILE" ]; then
  echo "Error: SQL file not found: $SQL_FILE"
  exit 1
fi

# Import the SQL file directly into MySQL
echo "Importing SQL file into MySQL database $DB_NAME..."

if [ -z "$DB_PASS" ]; then
  # No password provided
  mysql -u "$DB_USER" "$DB_NAME" < "$SQL_FILE"
else
  # Password provided
  mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"
fi

if [ $? -eq 0 ]; then
  echo "SQL import completed successfully."
else
  echo "Error: SQL import failed."
  exit 1
fi
