#!/usr/bin/env bash

alias dc="docker-compose \
    --project-directory ${COMPOSE_PROJECT_DIR} \
    --file ${COMPOSE_PROJECT_DIR}/docker-compose.yaml \
    $@"

alias make="dc \
    exec python make -C _build $@"
