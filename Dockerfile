FROM php:8.3-cli

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    zip \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy files
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Laravel permission fix
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# Expose port 8000
EXPOSE 8000

# Start Laravel with migration
CMD php artisan config:clear && \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=8000
