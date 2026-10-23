FROM debian:bookworm

# Install NGINX and OpenSSL.
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create the directory for TLS certificates.
RUN mkdir -p /etc/nginx/ssl

# Generate a self-signed TLS certificate.
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=wheino.42.fr"

# Restrict access to the private key.
RUN chmod 600 /etc/nginx/ssl/nginx.key

# Copy our website configuration.
COPY conf/nginx.conf /etc/nginx/sites-enabled/default

# Run NGINX in the foreground.
CMD ["nginx", "-g", "daemon off;"]
