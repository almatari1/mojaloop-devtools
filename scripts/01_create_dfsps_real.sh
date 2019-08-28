#!/usr/bin/env bash

##
# Sets up the demo DFSPs
#
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source $DIR/../config/.compiled_env

source $DIR/../config/colors.sh

CURRENCY=USD
CENTRAL_LEDGER_HOST=localhost:3001
# SIMULATOR_HOST=simulator.moja-box.vessels.tech - cloud kube env
# SIMULATOR_HOST=localhost:8444 - everything is local env
SIMULATOR_HOST=simulator:8444 #- docker env
DFSP_HOST_1=host.docker.internal:4000
# SIMULATOR_HOST=host.docker.internal #switch is running in docker, dfsps are not

logStep "Creating payerfsp and payeefsp"

curl -X POST \
  http://${CENTRAL_LEDGER_HOST}/participants \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "name": "payerfsp",
	"currency":"'$CURRENCY'"
}'


curl -X POST \
  http://${CENTRAL_LEDGER_HOST}/participants/payerfsp/initialPositionAndLimits \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "currency": "'$CURRENCY'",
    "limit": {
    	"type": "NET_DEBIT_CAP",
    	"value": 1000
    },
    "initialPosition": 100
  }'


curl -X POST \
  http://${CENTRAL_LEDGER_HOST}/participants \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "name": "payeefsp",
	"currency":"'$CURRENCY'"
}'


curl -X POST \
  http://${CENTRAL_LEDGER_HOST}/participants/payeefsp/initialPositionAndLimits \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "currency": "'$CURRENCY'",
    "limit": {
    	"type": "NET_DEBIT_CAP",
    	"value": 1000
    },
    "initialPosition": 100
  }'

logStep
logStep 'Setting up Simulated endpoints for Transfer'


# Transfer Endpoints - payerfsp

function registerEndpoint {
  DFSP=$1
  DATA=$2

  logSubStep "Registering DFSP: ${DFSP} with data: ${DATA}"
  curl -X POST \
    http://${CENTRAL_LEDGER_HOST}/participants/${DFSP}/endpoints \
    -H 'Content-Type: application/json' \
    -H 'Host: central-ledger.local' \
    -d "${DATA}"
}

registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT\", \"value\": \"http://${DFSP_HOST_1}/participants/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT_ERROR\", \"value\": \"http://${DFSP_HOST_1}/participants/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT\", \"value\": \"http://${DFSP_HOST_1}/participants/{{requestId}}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT_ERROR\", \"value\": \"http://${DFSP_HOST_1}/participants/{{requestId}}/error\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_GET\", \"value\": \"http://${DFSP_HOST_1}/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT\", \"value\": \"http://${DFSP_HOST_1}/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT_ERROR\", \"value\": \"http://${DFSP_HOST_1}/parties/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_QUOTES\", \"value\": \"http://${DFSP_HOST_1}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_POST\", \"value\": \"http://${DFSP_HOST_1}/transfers\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_PUT\", \"value\": \"http://${DFSP_HOST_1}/payerfstransfers/{{transferId}}\" }"
registerEndpoint payerfsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_ERROR\", \"value\": \"http://${DFSP_HOST_1}/transfers/{{transferId}}/error\" }"

registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/participants/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT_ERROR\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/participants/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/participants/{{requestId}}\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT_ERROR\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/participants/{{requestId}}/error\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_GET\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT_ERROR\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/parties/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_QUOTES\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_POST\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/transfers\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_PUT\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/transfers/{{transferId}}\" }"
registerEndpoint payeefsp "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_ERROR\", \"value\": \"http://${SIMULATOR_HOST}/payeefsp/transfers/{{transferId}}/error\" }"
