FROM php:8.2-fpm-alpine

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
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Set proper permissions
RUN addgroup -g 1000 www && \
    adduser -G www -g www -s /bin/sh -D www && \
    chown -R www:www /var/www/html /var/log/nginx /run/nginx

# Switch to non-root user
USER www

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Start services
CMD ["/start.sh"]
