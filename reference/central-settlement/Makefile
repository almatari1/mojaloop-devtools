PROJECT = "central-settlement tests"
dir = $(shell pwd)
include integration-runner.env.sh
export $(shell sed 's/=.*//' integration-runner.env)

##
# Start Required Services
## 
start:
	@make start_network start_simulator start_ml_api_adapter start_central_ledger start_db

start_network:
	docker network create ${DOCKER_NETWORK}

start_simulator:
	docker run --rm -td \
    -p 8444:8444 \
    --network ${DOCKER_NETWORK} \
    --name=${SIMULATOR_HOST} \
    --env TRANSFERS_ENDPOINT=http://${ML_API_ADAPTER_HOST}:3000 \
		--env LOG_LEVEL=debug \
    ${SIMULATOR_IMAGE}:${SIMULATOR_IMAGE_TAG}

start_ml_api_adapter:
	docker run --rm -td \
		-p 3000:3000 \
		--network ${DOCKER_NETWORK} \
		--name=${ML_API_ADAPTER_HOST} \
		--volume ${dir}/integration-config-mlapiadapter.json:/opt/ml-api-adapter/config/default.json \
    --env MLAPI_ENDPOINT_HEALTH_URL="http://${CENTRAL_LEDGER_HOST}:3001/health" \
		--env LOG_LEVEL=debug \
		${ML_API_ADAPTER_IMAGE}:${ML_API_ADAPTER_TAG} \
		sh -c "node src/api/index.js"

start_central_ledger:
	docker run --rm -td \
		-p 3001:3001 \
		--network ${DOCKER_NETWORK} \
		--name=${CENTRAL_LEDGER_HOST} \
		--volume ${dir}/integration-config-centralledger.json:/opt/central-ledger/config/default.json \
		--env CLEDG_DATABASE_URI="mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}" \
		--env LOG_LEVEL=debug \
		${CENTRAL_LEDGER_IMAGE}:${CENTRAL_LEDGER_TAG}

start_db:
	docker run -td \
		-p ${DB_PORT}:${DB_PORT} \
		--name ${DB_HOST} \
		--network ${DOCKER_NETWORK} \
		-e MYSQL_USER=${DB_USER} \
		-e MYSQL_PASSWORD=${DB_PASSWORD} \
		-e MYSQL_DATABASE=${DB_NAME} \
		-e MYSQL_ALLOW_EMPTY_PASSWORD=true \
		${DB_IMAGE}:${DB_TAG}


##
# Stop Services
## 
stop:
	@>&1 echo "Kafka is shutting down ${KAFKA_HOST}"
	@(docker stop ${KAFKA_HOST} && docker rm ${KAFKA_HOST}) > /dev/null 2>&1 || echo "Already stopped"
	@>&1 echo "${SIMULATOR_HOST} environment is shutting down"
	@(docker stop ${SIMULATOR_HOST} && docker rm ${SIMULATOR_HOST}) > /dev/null 2>&1 || echo "Already stopped"
	@>&1 echo "${CENTRAL_LEDGER_HOST} environment is shutting down"
	@(docker stop ${CENTRAL_LEDGER_HOST} && docker rm ${CENTRAL_LEDGER_HOST}) > /dev/null 2>&1 || echo "Already stopped"
	@>&1 echo "${ML_API_ADAPTER_HOST} environment is shutting down"
	@(docker stop ${ML_API_ADAPTER_HOST} && docker rm ${ML_API_ADAPTER_HOST}) > /dev/null 2>&1 || echo "Already stopped"
	@>&1 echo "${DB_HOST} environment is shutting down"
	@(docker stop ${DB_HOST} && docker rm ${DB_HOST}) > /dev/null 2>&1 || echo "Already Stopped"
	@>&1 echo "${APP_HOST} environment is shutting down"
	@(docker stop ${APP_HOST} && docker rm ${APP_HOST}) > /dev/null 2>&1 || echo "Already Stopped"
	@>&1 echo "Deleting test network: ${DOCKER_NETWORK}"
	@(docker network rm ${DOCKER_NETWORK}) > /dev/null 2>&1 || echo "Already removed"


##
# Liveness checks
## 

is_up:
	@make is_kafka_up
	@make is_db_up
	@make is_simulator_up
	@make is_central_ledger_up
	@make is_ml_api_adapter_up

is_kafka_up:
	$(call fkafka, 'kafka-topics.sh --list --zookeeper ${KAFKA_HOST}:${KAFKA_ZOO_PORT}')

is_db_up:
	$(call fdb, 'mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "select 1"')

is_simulator_up:
	$(call fcurl, http://${SIMULATOR_HOST}:8444/health)

is_central_ledger_up:
	$(call fcurl, http://${CENTRAL_LEDGER_HOST}:3001/health?)

is_ml_api_adapter_up:
	$(call fcurl, "http://${ML_API_ADAPTER_HOST}:3000/health?)


##
# Pre-test config
## 
wait_for_services:
	@echo 'Waiting for all services to be ready'
	@make is_up > /dev/null
	echo 'result is ${&?}'
	# TODO: check result, and re run if needed
	# make wait_for_services
	exit 0

run_migrations:
	$(call fcmd_centralledger,apk add --no-cache nodejs-npm && npm install npm-run-all && npm run migrate)

run_migrations_no_install:
	$(call fcmd_centralledger,npm run migrate)



##
# Run Tests
## 


##
# Functions
## 
define fcurl
	docker run --rm -i \
		--network ${DOCKER_NETWORK} \
		--entrypoint curl \
		"jlekie/curl:latest" \
		--silent --head --fail \
		"$@"
endef

define fkafka
	docker run --rm -i \
		--link ${KAFKA_HOST} \
		--network ${DOCKER_NETWORK} \
		--env KAFKA_HOST="${KAFKA_HOST}" \
		--env KAFKA_ZOO_PORT="${KAFKA_ZOO_PORT}" \
		taion809/kafka-cli \
		/bin/sh \
		-c "$(1)"
endef

define fdb
	docker run -it --rm \
		--link ${DB_HOST}:mysql \
		--network ${DOCKER_NETWORK} \
		-e DB_HOST=${DB_HOST} \
		-e DB_PORT=${DB_PORT} \
		-e DB_PASSWORD=${DB_PASSWORD} \
		-e DB_USER=${DB_USER} \
		-e DB_NAME=${DB_NAME} \
		mysql \
		sh -c $(1)
endef

define fcmd_centralledger
	docker run -i \
		--link ${KAFKA_HOST} \
		--link ${DB_HOST} \
		--network ${DOCKER_NETWORK} \
		--env HOST_IP=${APP_HOST"} \
		--env CLEDG_DATABASE_URI="mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}" \
		${CENTRAL_LEDGER_IMAGE}:${CENTRAL_LEDGER_TAG} \
		/bin/sh \
		-c "$(1)"
endef




.PHONY: start