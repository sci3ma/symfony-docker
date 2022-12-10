# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP_CONT) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down logs sh composer vendor sf cc ci phpstan pest phpcsfixer phpmd

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (no logs)
	@XDEBUG_MODE=coverage $(DOCKER_COMP) up --detach

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

restart: down up ## Restart docker containers

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

ps: ## Show containers
	@${DOCKER_COMP} ps

sh: ## Connect to the PHP FPM container
	@$(PHP_CONT) sh

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

## —— Analyze ——————————————————————————————————————————————————————————————————
ci: ## Run full analysis
ci: phpcsfixer
ci: phpstan
ci: pest
ci: phpmd

phpstan: ## Analyze codebase with PHPStan
	@$(PHP_CONT) vendor/bin/phpstan

pest: ## Run tests
	@$(PHP_CONT) vendor/bin/pest --coverage --parallel --min=95

phpcsfixer: ## Fix codebase with PHP Coding Standards Fixer
	@$(PHP_CONT) vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.dist.php -v --show-progress=dots

phpmd: ## Analyze codebase with PHP Mess Detector
	@$(PHP_CONT) vendor/bin/phpmd src/ ansi phpmd.ruleset.xml
