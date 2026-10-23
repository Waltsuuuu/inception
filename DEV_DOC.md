# Developer documentation

## Prerequisites

Use a Debian virtual machine with Docker Engine, the Docker Compose plugin, and Make installed. The VM must allow inbound HTTPS on port 443. Configure `wheino.42.fr` to resolve to the VM (inside the VM, `127.0.0.1 wheino.42.fr` in `/etc/hosts` works).

## Configuration from scratch

Create `srcs/.env` with these variables (replace example emails as needed):

```dotenv
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_URL=https://wheino.42.fr
WP_TITLE=Inception
WP_ADMIN_USER=wpowner
WP_ADMIN_EMAIL=wpowner@example.com
WP_USER=wpmember
WP_USER_EMAIL=wpmember@example.com
```

Create these local password files, each containing its respective password:

```text
secrets/db_root_password.txt
secrets/db_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Do not commit `.env` or `secrets/`. The WordPress administrator username must not contain `admin` or `administrator` (case-insensitive).

## Build and launch

From the project root:

```sh
make
```

The Makefile creates `/home/wheino/data/mariadb` and `/home/wheino/data/wordpress`, then runs Docker Compose with `srcs/.env` and `srcs/docker-compose.yml`. MariaDB initializes its database; the WordPress startup script installs WordPress and creates the configured users on first launch. NGINX generates a self-signed certificate at image build time.

## Manage the stack

```sh
make down                        # Remove containers/network; retain volumes and data
make stop                        # Stop containers
make start                       # Start existing containers
make re                          # Recreate containers

docker ps                        # Running containers
docker logs wordpress            # Inspect a service's logs
docker volume ls                 # Named volumes
docker volume inspect srcs_mariadb_data
```

For direct Compose commands:

```sh
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

## Storage and persistence

- `srcs_mariadb_data` → `/home/wheino/data/mariadb` (database, including posts, users and settings)
- `srcs_wordpress_data` → `/home/wheino/data/wordpress` (WordPress files, plugins, themes and uploads)

Both are Docker named volumes configured with local bind mounts. Removing or rebuilding containers does not erase these directories. To reset the installation, first stop the stack and deliberately remove the corresponding stored data; this permanently deletes the site/database. Avoid `down -v` unless you specifically intend to remove volume definitions.
