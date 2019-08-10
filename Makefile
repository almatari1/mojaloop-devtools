PROJECT = "central-settlement tests"
dir = $(shell pwd)

red:=$(shell tput setaf 1)
grn:=$(shell tput setaf 2)
ylw:=$(shell tput setaf 3)
blu:=$(shell tput setaf 4)
cyn:=$(shell tput setaf 5)
reset:=$(shell tput sgr0)

#set the services in ./config/services.conf
services = $(shell grep -v '^;' ./config/services.conf)

##
# Devtools Setup
##
build: build-docker-pull build-start-mysql
	
build-docker-pull:
	$(info $(cyn)[Pulling Docker]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml pull
	@touch build-docker-pull

build-start-mysql:
	$(info $(cyn)[Starting mysql container init process]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml up -d mysql
	./scripts/util/_wait_for_mysql_init.sh
	docker-compose -f ./docker/docker-compose.base.yml stop mysql
	@touch build-start-mysql


##
# Start Services
#
# Start Mojaloop services locally using docker-compose
## 
start: build start-all

##
# Start docker-compose in default mode:
# - all services inside of docker
# - use prebuilt docker images instead of building manually
##
start-all:
	$(info $(cyn)[Starting in default mode]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml up -d ${services}

##
# Start docker-compose in the following manner:
# - base file of ./docker/docker-compose.base.yml
# - build and run ml-api-adapter from local code
##
start-ml-local:
	@make build
	$(info $(cyn)[Starting with local ml-api-adapter]$(reset))
	docker-compose \
		-f ./docker/docker-compose.base.yml \
		-f ./docker/docker-compose.ml-local.yml \
		build
	docker-compose \
		-f ./docker/docker-compose.base.yml \
		-f ./docker/docker-compose.ml-local.yml \
		up -d ${services} ml-api-adapter-endpoint

##
# Start docker-compose in the following manner:
# - base file of ./docker/docker-compose.base.yml
# - build and run central-ledger from local code
##
start-cl-local:
	@make build
	$(info $(cyn)[Starting with local central-ledger]$(reset))
	docker-compose \
		-f ./docker/docker-compose.base.yml \
		-f ./docker/docker-compose.cl-local.yml \
		build
	docker-compose \
		-f ./docker/docker-compose.base.yml \
		-f ./docker/docker-compose.cl-local.yml \
		up -d ${services}


##
# Stop Services
## 
stop:
	docker-compose -f ./docker/docker-compose.base.yml stop


##
# Pre-test config
## 
test-config: test-config-migrate test-config-setup

test-config-migrate:
	$(info $(cyn)[Running migrations from `central-ledger`]$(reset))
	# ./scripts/util/_wait_for_centralledger_init.sh
	$(call fcmd_centralledger,"npm run migrate")
	@touch test-config-migrate

test-config-setup:
	$(info $(cyn)[Setting up test config]$(reset))
	@./scripts/00_set_up_env.sh
	@./scripts/01_create_dfsps.sh
	@touch test-config-setup

##
# Run Tests
## 
test-integration-ml-api:
	$(info $(cyn)[Running integration tests for ml-api-adapter]$(reset))
	$(call fcmd_mlapiadapter,"ENDPOINT_URL=ml-api-adapter-endpoint:4545 npm run test:int")

test-integration-central-ledger:
	$(info $(cyn)[Running integration tests for central-ledger]$(reset))
	$(call fcmd_centralledger,"npm run test:int")


##
# Utils
##
log:
	docker-compose -f ./docker/docker-compose.base.yml \
		logs -f ${services}

get_positions:
	@./scripts/_get_positions.sh


##
# Reset MySQL container and re-run migrations
##
reset-mysql:
	@make stop reset-mysql-build reset-test-config build-start-mysql
	# TODO: can re-run whatever the last start command was?
	@make start
	# TODO: fix issues where central_ledger migrations are locked...
	@make test-config



##
# Cleanup
##
clean: remove-containers reset-pull-status reset-mysql-build reset-test-config

remove-containers:
	$(info $(cyn)[Removing all container]$(reset))
	@docker rm -f dt_mysql 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_ml-api-adapter 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_central-ledger 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_kafka 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_mockserver 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_simulator 2>&1  > /dev/null || echo 'Done'
	@docker rm -f dt_ml-api-adapter-endpoint 2>&1  > /dev/null || echo 'Done'

reset-pull-status:
	@rm -f build-docker-pull

reset-mysql-build:
	$(info $(cyn)[Removing mysql container]$(reset))
	@docker rm -f dt_mysql 2>&1  > /dev/null || echo 'Already removed'
	@rm -f build-start-mysql

reset-test-config:
	@rm -f test-config-setup
	@rm -f test-config-migrate

##
# Functions
##

define fcmd_centralledger
	docker exec -it dt_central-ledger /bin/sh -c $(1)
endef

define fcmd_mlapiadapter
	docker exec -it dt_ml-api-adapter /bin/sh -c $(1)
endef


.PHONY: start stop clean