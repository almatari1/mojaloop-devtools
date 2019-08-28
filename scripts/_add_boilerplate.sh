#!/usr/bin/env bash

##
# run this in different steps:
# STEP=1: open the repos for manually forking
# STEP=2: clone repos, set up git and add boilerplate
# STEP=3: Push changes upstream and open PR 
# STEP=-1: Delete remote branches, clean up local files
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/colors.sh
MOJALOOP_DIR="${DIR}/../.."
BP_DIR="$MOJALOOP_DIR/bp"

mkdir -p ${BP_DIR}

# Test with just 3
REPOS="dfsp-account dfsp-admin dfsp-api"
# REPOS="dfsp-account dfsp-admin dfsp-api dfsp-directory dfsp-identity dfsp-ledger dfsp-mock dfsp-rule dfsp-scheme-adapter dfsp-subscription dfsp-transfer central-hub  central-end-user-registry interop-ilp-conditions"

##Constants
REPO_PREFIX=""
BRANCH_NAME="feature/948-add-deprecation-notice"
BOILERPLATE_TEXT="# [DEPRECATED] [service name] service

## Deprecation Notice

The [service name] service was deprecated as of January 2018. This service is no longer maintained as it is no longer in the scope of the Mojaloop OSS community. [insert specific notes, e.g.: There are currently no alternatives to simulate USSD behaviour, however for other Mojaloop DFSP simulator needs, refer to the general [Simulator](https://github.com/mojaloop/simulator).]

For a list of active Mojaloop repos, please refer to the list maintained in the [documentation](todo).
"

function openRepo() {
  REPO=$1

  logSubStep "opening mojaloop repo: ${REPO}"
  open "https://github.com/mojaloop/${REPO}"
}

function cloneRepo() {
  REPO=$1
  REPO_PATH=${BP_DIR}/${REPO_PREFIX}${REPO}

  if [ -d ${REPO_PATH} ]; then
    logNote "Repo already cloned";
  else
    logSubStep "checking out repo: ${REPO} to ${REPO_PATH}"
    git clone git@github.com:vessels-tech/${REPO}.git ${REPO_PATH}
    cd ${REPO_PATH}

    git remote add mojaloop git@github.com:mojaloop/${REPO}.git
    git pull mojaloop master
    git checkout -b ${BRANCH_NAME}
  fi
}

function addBoilerplate() {
  REPO=$1
  REPO_PATH=${BP_DIR}/${REPO_PREFIX}${REPO}

  logSubStep "adding boiler plate to repo: ${REPO}"
  # sed -i '' '1s/^/task goes here\n' ${REPO_PATH}/README.md
  printf "${BOILERPLATE_TEXT}" > ${REPO_PATH}/README_new.md
  cat ${REPO_PATH}/README.md >> ${REPO_PATH}/README_new.md
  mv ${REPO_PATH}/README_new.md ${REPO_PATH}/README.md
}

function pushUpstreamAndPR() {
  REPO=$1
  REPO_PATH=${BP_DIR}/${REPO_PREFIX}${REPO}

  logSubStep "pushing upstream repo: ${REPO}"

  cd ${REPO_PATH}
  git commit -am "Add deprecation boilerplate"
  git push -u origin ${BRANCH_NAME}

  logSubStep "opening PR link: ${REPO}"
  open "https://github.com/vessels-tech/${REPO}/pull/new/${BRANCH_NAME}"
}

function deleteBranch() {
  REPO=$1
  REPO_PATH=${BP_DIR}/${REPO_PREFIX}${REPO}

  cd ${REPO_PATH}
  git push --delete origin ${BRANCH_NAME}
}

for repo in $REPOS; do
  #only do this once so we can fork to VT manually
  if [ $STEP -eq 1 ]; then
    openRepo $repo 
  fi

  if [ $STEP -eq 2 ]; then
    #clone, add remotes, pull master, checkout new branch
    cloneRepo $repo

    #add boilerplate to readme maybe just append to the start and rely on us to fix manually
    addBoilerplate $repo
  fi

  if [ $STEP -eq 3 ]; then
    #push upstream
    pushUpstreamAndPR $repo
  fi

  if [ $STEP -eq -1 ]; then
    #delete the branch on the remote
    deleteBranch $repo
  fi

done

if [ $STEP -eq -1 ]; then
  #delete the folder
  rm -rf ${BP_DIR}
fi