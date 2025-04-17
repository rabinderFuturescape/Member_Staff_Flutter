#!/bin/bash

# This script resets the database and reloads the mock data

# Check if we're using Docker
if [ -f "docker-compose.yml" ]; then
  echo "Docker environment detected. Using Docker commands..."
  
  # Reset the database
  docker-compose exec app php artisan migrate:fresh
  
  # Check if SQL file exists
  if [ -f "database/seeders/sql/mock_member_staff_seed.sql" ]; then
    echo "SQL file found. Importing directly..."
    
    # Get database credentials from .env file
    DB_DATABASE=$(grep DB_DATABASE .env | cut -d '=' -f2)
    DB_USERNAME=$(grep DB_USERNAME .env | cut -d '=' -f2)
    DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2)
    
    # Import SQL file directly
    docker-compose exec db mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < database/seeders/sql/mock_member_staff_seed.sql
  else
    echo "SQL file not found. Using seeders..."
    docker-compose exec app php artisan db:seed
  fi
else
  echo "Local environment detected. Using local commands..."
  
  # Reset the database
  php artisan migrate:fresh
  
  # Check if SQL file exists
  if [ -f "database/seeders/sql/mock_member_staff_seed.sql" ]; then
    echo "SQL file found. Importing directly..."
    
    # Get database credentials from .env file
    DB_DATABASE=$(grep DB_DATABASE .env | cut -d '=' -f2)
    DB_USERNAME=$(grep DB_USERNAME .env | cut -d '=' -f2)
    DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2)
    
    # Import SQL file directly
    mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < database/seeders/sql/mock_member_staff_seed.sql
  else
    echo "SQL file not found. Using seeders..."
    php artisan db:seed
  fi
fi

echo "Database reset completed."
