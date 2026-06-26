#!/bin/bash
set -e

if [ ! -f /var/www/html/include/ost-config.php ]; then
    if [ -f /var/www/html/include/ost-sampleconfig.php ]; then
        cp /var/www/html/include/ost-sampleconfig.php /var/www/html/include/ost-config.php
        echo "ost-config.php created from sample"
    fi
fi

if [ -f /var/www/html/include/ost-config.php ]; then
    chown www-data:www-data /var/www/html/include/ost-config.php 2>/dev/null || true
    chmod 640 /var/www/html/include/ost-config.php 2>/dev/null || true
fi

for dir in /var/www/html/include /var/www/html/assets /var/www/html/scp/css /var/www/html/scp/js; do
    if [ -d "$dir" ]; then
        chown -R www-data:www-data "$dir" 2>/dev/null || true
    fi
done

service cron start

echo "Starting Apache..."
apache2-foreground