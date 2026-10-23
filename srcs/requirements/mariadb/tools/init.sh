#!/bin/sh

# Stop the script if any command fails.
set -e

# Read the database passwords from Docker secrets.
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Check that all required configuration values are present.
: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${DB_ROOT_PASSWORD:?Root password is missing}"
: "${DB_PASSWORD:?Database user password is missing}"

# Create the database directory and the directory for MariaDB's Unix socket.
mkdir -p /var/lib/mysql /run/mysqld

# Give the mysql user and group ownership of both directories.
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize MariaDB's system tables if they don't already exist.
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Configure the WordPress database if initialization hasn't completed.
if [ ! -f /var/lib/mysql/.initialized ]; then

    # Start MariaDB temporarily, using a local Unix socket.
    mariadbd --user=mysql --skip-networking &
    MYSQL_PID=$!

    # Wait until MariaDB is ready to accept connections.
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # Create the WordPress database and its dedicated user.
    mariadb -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.*
TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${DB_ROOT_PASSWORD}';
SQL

    # Stop the temporary MariaDB server after initialization.
    mariadb-admin -u root --password="$DB_ROOT_PASSWORD" shutdown

    # Wait for the temporary server to stop completely.
    wait "$MYSQL_PID"

    # Mark initialization as complete.
    touch /var/lib/mysql/.initialized
fi

# Start MariaDB as the container's main process.
exec mariadbd --user=mysql --console
