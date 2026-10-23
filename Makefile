COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

DATA_DIR = /home/wheino/data

all:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

re:
	$(COMPOSE) down
	$(MAKE) all

.PHONY: all down stop start re