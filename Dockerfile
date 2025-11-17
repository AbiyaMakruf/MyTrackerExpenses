# ============================================
# 1. Stage 1 - Build Frontend Assets (Node)
# ============================================
FROM node:20-slim AS build

# Terima ARGumen build untuk kunci Pusher
# Ini akan disuntikkan dari GitHub Actions
ARG VITE_PUSHER_APP_KEY

# Working directory
WORKDIR /app

# Copy package files dan install dependencies
COPY package*.json vite.config.* ./
# Gunakan 'npm install' tanpa 'ci' jika Anda ingin cache lebih baik
RUN npm install

# Copy semua source code untuk build
COPY . .

# Buat file .env sementara dari ARG yang diterima
# Vite akan secara otomatis mengambil variabel yang diawali dengan VITE_ dari file .env
RUN echo "VITE_PUSHER_APP_KEY=${VITE_PUSHER_APP_KEY}" > .env

# Build Vite assets (public/build)
# Proses ini sekarang menggunakan VITE_PUSHER_APP_KEY yang disuntikkan
RUN npm run build

# ============================================
# 2. Stage 2 - Laravel + PHP-FPM + Nginx
# ============================================
FROM php:8.3-fpm

# Working directory
WORKDIR /var/www/html

# Install dependencies PHP dan Sistem
RUN apt-get update && apt-get install -y \
    nginx supervisor git unzip curl zip \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_pgsql zip bcmath \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Copy Laravel source code (termasuk .git, yang mungkin tidak ideal tapi sesuai dengan flow Anda)
COPY . .

# Copy compiled frontend build dari tahap Node
COPY --from=build /app/public/build /var/www/html/public/build

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Add custom PHP upload limits
COPY ./docker/custom.ini /usr/local/etc/php/conf.d/custom-upload-limits.ini

# Optimize Laravel

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Copy Nginx & Supervisor config
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/default.conf /etc/nginx/sites-available/default
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port yang akan digunakan Nginx
EXPOSE 8080

# Command utama untuk menjalankan Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]