#!/bin/bash
set -e

# Create storage directories if they don't exist
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views

# Set proper permissions
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Clear cache
php artisan optimize:clear

# Run migrations if needed (optional, can be disabled in production)
if [[ "${RUN_MIGRATIONS}" == "true" ]]; then
    php artisan migrate --force
fi

# Start supervisord
exec supervisord -c /etc/supervisord.conf
