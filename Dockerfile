FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libzip-dev \
    libjpeg-dev \
    libpq-dev \
    default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath zip gd

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /workspace

# Copy source code
COPY . .

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set Apache config for Laravel (optional, good for .htaccess support)
RUN echo '<Directory /workspace/public>\n\
    AllowOverride All\n\
</Directory>' >> /etc/apache2/apache2.conf

# Fix permissions (required for Laravel to write logs/cache)
RUN chown -R www-data:www-data /workspace/storage /workspace/bootstrap/cache

# Expose Apache port
EXPOSE 8000

# Start Apache
CMD ["apache2-foreground"]
