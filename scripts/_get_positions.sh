#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/colors.sh
source $DIR/../config/.compiled_env

function getPosition {
  DFSP=$1

  logSubStep "Getting DFSP: ${DFSP}"
  curl -X GET \
    http://${CENTRAL_LEDGER_HOST}/participants/${DFSP}/positions \
    -H 'Content-Type: application/json' \
    -H 'Host: central-ledger.local'
}

logStep "Getting DFSP Positions"
getPosition payeefsp
getPosition payerfsp