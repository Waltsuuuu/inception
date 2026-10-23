# User documentation

## Services

The stack provides a WordPress website through NGINX (HTTPS) with a MariaDB database. WordPress and MariaDB are not exposed directly to the host.

## Start and stop

From the project root in the VM:

```sh
make          # Build and start
make stop     # Stop
make start    # Start again
make down     # Stop and remove containers, keeping data
```

## Access

- Website: **https://wheino.42.fr**
- Administration: **https://wheino.42.fr/wp-admin/**

The domain must resolve to the VM. A browser warning is expected because NGINX uses a self-signed certificate.

## Credentials

The WordPress administrator username is set by `WP_ADMIN_USER` in `srcs/.env`; the regular username is set by `WP_USER`. Passwords are stored locally in `secrets/wp_admin_password.txt` and `secrets/wp_user_password.txt`. MariaDB passwords are in `secrets/db_password.txt` and `secrets/db_root_password.txt`.

Keep these files private and out of Git. Changing a password file after initial installation does **not** automatically change the password stored in WordPress or MariaDB.

## Check status

```sh
docker ps                       # Three running containers: nginx, wordpress, mariadb
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Open the website and sign in to confirm that the application works.
