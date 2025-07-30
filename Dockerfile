# Use official PHP with Apache image
FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Set working directory
WORKDIR /workspace

# Copy all files
COPY . .

# Set proper document root to Laravel's public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /workspace/public|g' /etc/apache2/sites-available/000-default.conf

# Optional: Fix Apache server name warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy Composer from Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /workspace/storage /workspace/bootstrap/cache

# Expose the correct port for Koyeb
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
