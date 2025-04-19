# Build stage
FROM composer:2 AS composer

WORKDIR /app

# Copy only the files needed for composer install
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Node.js build stage (if needed)
FROM node:18-alpine AS node

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build assets
RUN npm run build

# Final stage
FROM php:8.2-fpm-alpine

# Build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Labels
LABEL org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.title="Secure Laravel App" \
      org.opencontainers.image.description="Secure Laravel application with ionCube encoding" \
      org.opencontainers.image.url="https://github.com/rabinderFuturescape/Member_Staff_Flutter" \
      org.opencontainers.image.revision=${VCS_REF} \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.vendor="Your Organization" \
      org.opencontainers.image.licenses="MIT"

# Install dependencies
RUN apk add --no-cache \
    nginx \
    bash \
    curl \
    tzdata \
    supervisor \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    opcache \
    bcmath \
    gd \
    zip

# Add ionCube loader
RUN curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    | tar -xz -C /usr/local \
    && cp /usr/local/ioncube/ioncube_loader_lin_8.2.so $(php -i | grep ^extension_dir | awk '{print $3}') \
    && echo "zend_extension=ioncube_loader_lin_8.2.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

# Configure PHP
COPY docker/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf

# Create directory structure
RUN mkdir -p /var/www/html /run/nginx /var/log/nginx

# Copy encoded Laravel code
COPY encoded-src/ /var/www/html

# Copy vendor directory from composer stage
COPY --from=composer /app/vendor/ /var/www/html/vendor/

# Copy built assets from node stage
COPY --from=node /app/public/build/ /var/www/html/public/build/

# Copy startup script
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Set proper permissions
RUN addgroup -g 1000 www && \
    adduser -G www -g www -s /bin/sh -D www && \
    chown -R www:www /var/www/html /var/log/nginx /run/nginx

# Security hardening
RUN apk del curl && \
    rm -rf /var/cache/apk/* && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    chmod 755 /start.sh

# Switch to non-root user
USER www

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start services
CMD ["/start.sh"]
