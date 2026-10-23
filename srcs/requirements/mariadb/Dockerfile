# Use Debian 12 as the base image.
FROM debian:bookworm

# Install MariaDB Server and remove cached package lists
# to reduce the image size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy our custom MariaDB configuration into the container.
# The 99- prefix ensures it loads after the default configurations.
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

# Copy the initialization script and make it executable.
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Run the initialization script when the container starts.
ENTRYPOINT ["/usr/local/bin/init.sh"]
