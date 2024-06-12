#!/bin/bash

while true; do
	
  # Referência de documentação - https://docs.docker.com/engine/reference/commandline/image_prune/
  docker system prune --all --force

  # DOCKER_CLEAN_INTERVAL 30min por padrão (variável Dockerfile)
  sleep $DOCKER_CLEAN_INTERVAL
done