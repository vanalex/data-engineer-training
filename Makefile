SHELL := /bin/sh

COMPOSE := docker compose
SERVICE := mysql

ENV_FILE := .env
MYSQL_DATABASE ?= training

.PHONY: help env-example config up start wait-db stop down restart ps logs logs-follow mysql mysql-root load-players run-pipeline reload-players reset-db python clean-pyc

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make env-example    Create .env from .env.example if it does not exist' \
		'  make config         Validate and print the Docker Compose config' \
		'  make up             Start MySQL in the background' \
		'  make start          Alias for up' \
		'  make wait-db        Wait until MySQL accepts connections' \
		'  make stop           Stop containers without removing them' \
		'  make down           Stop and remove containers' \
		'  make restart        Restart MySQL' \
		'  make ps             Show container status' \
		'  make logs           Show recent MySQL logs' \
		'  make logs-follow    Follow MySQL logs' \
		'  make mysql          Open a MySQL shell as MYSQL_USER' \
		'  make mysql-root     Open a MySQL shell as root' \
		'  make load-players   Create/recreate the players table' \
		'  make run-pipeline   Run scripts/dimensional_data_modeling/pipeline_players.sql' \
		'  make reload-players Recreate players table and run the pipeline' \
		'  make reset-db       Remove containers and volumes, then start fresh' \
		'  make python         Run main.py' \
		'  make clean-pyc      Remove Python cache files'

env-example:
	@test -f $(ENV_FILE) || cp .env.example $(ENV_FILE)

config: env-example
	$(COMPOSE) --env-file $(ENV_FILE) config

up: env-example
	$(COMPOSE) --env-file $(ENV_FILE) up -d

start: up

wait-db: up
	$(COMPOSE) --env-file $(ENV_FILE) exec -T $(SERVICE) sh -lc 'until mysqladmin ping -h127.0.0.1 -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD" --silent; do sleep 2; done'

stop:
	$(COMPOSE) --env-file $(ENV_FILE) stop

down:
	$(COMPOSE) --env-file $(ENV_FILE) down

restart:
	$(COMPOSE) --env-file $(ENV_FILE) restart $(SERVICE)

ps:
	$(COMPOSE) --env-file $(ENV_FILE) ps

logs:
	$(COMPOSE) --env-file $(ENV_FILE) logs --tail=100 $(SERVICE)

logs-follow:
	$(COMPOSE) --env-file $(ENV_FILE) logs -f $(SERVICE)

mysql: wait-db
	$(COMPOSE) --env-file $(ENV_FILE) exec $(SERVICE) sh -lc 'mysql -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE"'

mysql-root: wait-db
	$(COMPOSE) --env-file $(ENV_FILE) exec $(SERVICE) sh -lc 'mysql -uroot -p"$$MYSQL_ROOT_PASSWORD" "$$MYSQL_DATABASE"'

load-players: wait-db
	$(COMPOSE) --env-file $(ENV_FILE) exec -T $(SERVICE) sh -lc 'mysql -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE" < /bootcamp/scripts/dimensional_data_modeling/players.sql'

run-pipeline: wait-db
	$(COMPOSE) --env-file $(ENV_FILE) exec -T $(SERVICE) sh -lc 'mysql -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE" < /bootcamp/scripts/dimensional_data_modeling/pipeline_players.sql'

reload-players: load-players run-pipeline

reset-db: env-example
	$(COMPOSE) --env-file $(ENV_FILE) down -v
	$(COMPOSE) --env-file $(ENV_FILE) up -d
	$(MAKE) wait-db

python:
	python3 main.py

clean-pyc:
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
