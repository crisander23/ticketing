FROM php:8.2-apache

# Step 1: Clean slate
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Step 2: All required libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    unzip \
    cron \
 && rm -rf /var/lib/apt/lists/*

# Step 3: Configure GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# Step 4: Install built-in PHP extensions (added ctype)
RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    gd \
    intl \
    mbstring \
    xml \
    zip \
    curl \
    fileinfo \
    ctype

# Step 5: Install APCu via PECL
RUN pecl install apcu \
 && docker-php-ext-enable apcu

# Step 6: Install IMAP via PECL (Bookworm fix - no libc-client needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc-client2007e-dev \
 || true \
 && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
 && docker-php-ext-install imap \
 || echo "IMAP skipped - not critical"

# Step 7: Enable Apache mod_rewrite
RUN a2enmod rewrite

# Step 8: PHP runtime config
RUN { \
    echo "upload_max_filesize = 20M"; \
    echo "post_max_size = 20M"; \
    echo "max_execution_time = 120"; \
    echo "memory_limit = 256M"; \
    echo "date.timezone = Asia/Manila"; \
    echo "apc.enabled = 1"; \
    echo "apc.shm_size = 128M"; \
} >> /usr/local/etc/php/php.ini

COPY apache-osticket.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

RUN echo "*/5 * * * * www-data php /var/www/html/api/cron.php > /dev/null 2>&1" \
    > /etc/cron.d/osticket \
 && chmod 0644 /etc/cron.d/osticket

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]