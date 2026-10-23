# Use Debian 12 as the base image.
FROM debian:bookworm

# Install PHP-FPM, PHP extensions, and curl.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download WP-CLI and make it executable.
RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Set the WordPress directory.
WORKDIR /var/www/html

# Copy the WordPress startup script into the container.
COPY tools/wordpress-entrypoint.sh /usr/local/bin/

# Make the script executable.
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# Run the script when the container starts.
ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
