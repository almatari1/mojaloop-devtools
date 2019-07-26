PROJECT = "central-settlement tests"
dir = $(shell pwd)
# include integration-runner.env.sh
# export $(shell sed 's/=.*//' integration-runner.env)

red:=$(shell tput setaf 1)
grn:=$(shell tput setaf 2)
ylw:=$(shell tput setaf 3)
blu:=$(shell tput setaf 4)
cyn:=$(shell tput setaf 5)
reset:=$(shell tput sgr0)

##
# Devtools Setup
##
build: build-docker-pull build-start-mysql
	
build-docker-pull:
	$(info $(cyn)[Pulling Docker]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml pull
	echo "done" > build-docker-pull

build-start-mysql:
	$(info $(cyn)[Starting mysql container init process]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml up -d mysql
	./scripts/util/_wait_for_mysql_init.sh
	docker-compose -f ./docker/docker-compose.base.yml stop mysql
	echo "done" > build-start-mysql


##
# Start Services
#
# Start Mojaloop services locally using docker-compose
## 
start: build start_all

##
# Start docker-compose in default mode:
# - all services inside of docker
# - use prebuilt docker images instead of building manually
##
start_all:
	$(info $(cyn)[Starting in default mode]$(reset))
	docker-compose -f ./docker/docker-compose.base.yml up -d



##
# Stop Services
## 
stop:
	docker-compose -f ./docker/docker-compose.base.yml stop


##
# Pre-test config
## 
run_migrations:
	$(call fcmd_centralledger,npm run migrate)


configure_test_environment:
	@./scripts/00_set_up_env.sh
	@./scripts/01_create_dfsps.sh

##
# Run Tests
## 


##
# Utils
##
log:
	docker-compose -f ./docker/docker-compose.base.yml \
		logs -f kafka ml-api-adapter central-ledger simulator

get_positions:
	@./scripts/_get_positions.sh


##
# Cleanup
##
clean: reset-pull-status remove_mysql

reset-pull-status:
	@rm -f build-docker-pull

remove_mysql:
	$(info $(cyn)[Removing mysql container]$(reset))
	@docker rm -f dt_mysql
	@rm -f build-start-mysql



.PHONY: start stop clean