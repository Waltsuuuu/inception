#!/bin/sh

# Stop the script if any command fails.
set -e

# Configure PHP-FPM to listen on port 9000 instead of a Unix socket.
sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Create the directory PHP-FPM needs at runtime.
mkdir -p /run/php

# Download WordPress only if it hasn't already been downloaded.
if [ ! -f /var/www/html/wp-includes/version.php ]; then
    wp core download --path=/var/www/html --allow-root
fi

# Read the WordPress database password from Docker secrets.
DB_PASSWORD=$(cat /run/secrets/db_password)

# Create the WordPress configuration if it doesn't already exist.
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --path=/var/www/html \
        --allow-root
fi

# Read the WordPress administrator password from Docker secrets.
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

# Wait until MariaDB is ready to accept connections.
until wp db check --path=/var/www/html --allow-root > /dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Install WordPress only if it hasn't already been installed.
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --path=/var/www/html \
        --allow-root
fi

# Read the regular user's password from Docker secrets.
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Create a regular WordPress user if it doesn't already exist.
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=subscriber \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
fi

# Allow PHP-FPM to read and modify WordPress files.
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in the foreground.
exec php-fpm8.2 -F
