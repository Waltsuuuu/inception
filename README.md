*This project has been created as part of the 42 curriculum by wheino.*

# Inception

## Description

Inception runs a WordPress website inside a Debian virtual machine using Docker Compose. Three custom Debian-based images provide separate services:

- **NGINX** — the only exposed service, serving HTTPS on port 443 with TLS 1.2/1.3.
- **WordPress + PHP-FPM** — serves PHP requests and installs WordPress using WP-CLI.
- **MariaDB** — stores the WordPress database.

The containers communicate on a dedicated Docker bridge network. Two Docker-managed volumes bind to `/home/wheino/data/mariadb` and `/home/wheino/data/wordpress` to persist data on the VM.

### Design choices

| Comparison | Choice and reason |
|---|---|
| Virtual machines vs Docker | A VM runs a full guest OS; Docker containers share the host kernel. This project runs Docker **inside a VM** as required. |
| Secrets vs environment variables | `.env` supplies non-secret configuration; Docker secrets supply passwords as mounted files. |
| Docker network vs host network | A dedicated bridge network allows service-name communication without exposing WordPress or MariaDB ports on the host. |
| Docker volumes vs bind mounts | Docker manages named volumes; here each volume uses a bind mount to a specified host directory so data remains under `/home/wheino/data`. |

## Instructions

Requires a Debian VM with Docker Engine, Docker Compose plugin, and Make installed. Create `srcs/.env` and the four files in `secrets/` as described in [DEV_DOC.md](DEV_DOC.md). Configure `wheino.42.fr` to resolve to the VM's local address (or `127.0.0.1` when browsing inside the VM).

From the repository root:

```sh
make          # Create data directories, build images, start services
make down     # Remove containers and network; preserve data
make stop     # Stop containers
make start    # Start existing containers
make re       # Recreate the stack
```

Visit **https://wheino.42.fr**. The self-signed TLS certificate causes an expected browser warning.

See [USER_DOC.md](USER_DOC.md) for usage and [DEV_DOC.md](DEV_DOC.md) for installation and maintenance.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/docs/)

**AI usage:** ChatGPT was used to explain Docker, Compose, shell scripts, NGINX, TLS, and WordPress setup; help draft and debug configuration; plan verification steps; and draft documentation. The configuration was tested in the VM.
