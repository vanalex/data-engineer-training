SHELL := /bin/sh

COMPOSE := docker compose
SERVICE := mysql

ENV_FILE := .env
SCRIPT_DIR := /bootcamp/scripts/dimensional_data_modeling

# wait-db polls this many times, sleeping WAIT_INTERVAL seconds between tries.
WAIT_RETRIES := 60
WAIT_INTERVAL := 2

DC := $(COMPOSE) --env-file $(ENV_FILE)

# Run mysql in the container as MYSQL_USER, with $(1) appended (an -e query or
# a < redirect). MYSQL_PWD keeps the password off the command line, which mysql
# otherwise warns about on every invocation.
mysql_run = $(DC) exec -T $(SERVICE) sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" mysql -u"$$MYSQL_USER" "$$MYSQL_DATABASE" $(1)'

.DEFAULT_GOAL := help

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
	$(DC) config

up: env-example
	$(DC) up -d

start: up

# The retry loop runs on the host: `docker compose exec` fails outright while
# the container is still starting, so a loop inside the container never gets a
# chance to wait. `mysql -e 'SELECT 1'` is used instead of `mysqladmin ping`,
# which exits 0 even when the server rejects the credentials.
wait-db: up
	@printf 'Waiting for MySQL '
	@i=0; \
	until $(call mysql_run,-e "SELECT 1") >/dev/null 2>&1; do \
		i=$$((i + 1)); \
		if [ $$i -ge $(WAIT_RETRIES) ]; then \
			printf ' timed out after %ss\n' $$((i * $(WAIT_INTERVAL))) >&2; \
			exit 1; \
		fi; \
		printf '.'; \
		sleep $(WAIT_INTERVAL); \
	done; \
	printf ' ready\n'

stop: env-example
	$(DC) stop

down: env-example
	$(DC) down

restart: env-example
	$(DC) restart $(SERVICE)

ps: env-example
	$(DC) ps

logs: env-example
	$(DC) logs --tail=100 $(SERVICE)

logs-follow: env-example
	$(DC) logs -f $(SERVICE)

mysql: wait-db
	$(DC) exec $(SERVICE) sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" mysql -u"$$MYSQL_USER" "$$MYSQL_DATABASE"'

mysql-root: wait-db
	$(DC) exec $(SERVICE) sh -c 'MYSQL_PWD="$$MYSQL_ROOT_PASSWORD" mysql -uroot "$$MYSQL_DATABASE"'

load-players: wait-db
	$(call mysql_run,< $(SCRIPT_DIR)/players.sql)

run-pipeline: wait-db
	$(call mysql_run,< $(SCRIPT_DIR)/pipeline_players.sql)

reload-players: load-players run-pipeline

reset-db: env-example
	$(DC) down -v
	$(MAKE) wait-db

python:
	python3 main.py

clean-pyc:
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
