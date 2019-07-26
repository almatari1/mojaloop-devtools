#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../../config/colors.sh

# wait for the dt_mysql container to finish its init process

CONTAINER_NAME=dt_central-ledger
WAIT_FOR_STRING="MySQL init process done. Ready for start up"

function waitFor() {
  lineCount=`docker logs ${CONTAINER_NAME} 2>&1 | grep "${WAIT_FOR_STRING}" | wc -l`
  if [ ${lineCount} -eq 0 ]; then
    return 1
  fi

  return 0
}

logStep "Waiting for ${CONTAINER_NAME} to finish init process"

until waitFor; do
  >&1 printf $cyn"."$white
  sleep 5
done

printf $cyn"DONE"$white