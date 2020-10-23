#!/bin/bash

set -e

export ANSI_YELLOW="\e[1;33m"
export ANSI_GREEN="\e[32m"
export ANSI_RESET="\e[0m"

echo -e "\n $ANSI_YELLOW *** FUNCTIONAL TEST(S) *** $ANSI_RESET \n"

echo -e "$ANSI_YELLOW Docker is running - docker.sock is mounted with read only mode: $ANSI_RESET"
docker build -t test/run-app/quay.io/ibmz/docker .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro test/run-app/quay.io/ibmz/docker version
docker rmi test/run-app/quay.io/ibmz/docker

echo -e "\n $ANSI_GREEN *** FUNCTIONAL TEST(S) COMPLETED SUCESSFULLY *** $ANSI_RESET \n"
