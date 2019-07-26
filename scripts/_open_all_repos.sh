#!/usr/bin/env bash

# Opens all mojaloop repos
ALL_PROJECTS="account-lookup-service;central-ledger;central-event-processor;email-notifier;ml-api-adapter;central-settlement;central-services-auth;central-services-database;central-services-error-handling;central-services-metrics;central-services-shared;central-services-stream;forensic-logging-sidecar;pathfinder-provisioning-client;pathfinder-query-client;quoting-service;simulator;"

# EXTENSION=""
EXTENSION="settings/branches"

for str in ${ALL_PROJECTS//;/ } ; do 
  open "https://github.com/mojaloop/${str}/${EXTENSION}"
done