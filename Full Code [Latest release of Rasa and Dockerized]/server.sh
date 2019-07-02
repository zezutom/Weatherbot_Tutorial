#!/bin/bash

RASA_CONFIG_DIR="config/rasa/"
MODEL_NAME="weather_model"
CONTAINER_NAME="rasa_all"

show_help() {
  echo "Usage:

    server.sh [build | start | stop] [-m | --mode [nlu | train | interactive]]

    Examples:
      
    server.sh start		.. just starts the docker container
    server.sh -m train		.. trains the NLU model
    server.sh build -m nlu	.. (re)builds the docker image and trains the NLU model

    Parameters:

    build	.. builds the docker image
    start	.. starts the docker container
    stop	.. stops the running container

    Options:

    -m | --mode	.. runs one of the modes below
      nlu		.. trains the NLU model
      train		.. trains the Rasa Core model
      interactive	.. starts interactive learning
  "
}

build_docker_image() {
  docker build . -t rasa/weatherbot
}

run_nlu() {
  if [[ ! $(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME") = "true" ]]; then
    start_docker_container
  fi	 
  docker exec -it rasa_all python nlu_model.py
}

run_train() {
  docker-compose run rasa train --data ['data'] \
        --config "$RASA_CONFIG_DIR/config.yml" \
        --domain "$RASA_CONFIG_DIR/domain.yml" \
        --out models \
        --augmentation 50 \
        --fixed-model-name $MODEL_NAME
}

run_interactive() {
  docker-compose run rasa interactive \
        -m "$MODEL_NAME.tar.gz" \
        --domain "$RASA_CONFIG_DIR/domain.yml" \
        --endpoints "$RASA_CONFIG_DIR/endpoints.yml"
}

start_docker_container() {
  docker-compose up -d
}

stop_docker_container() {
  docker-compose down
}

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -m|--mode)
      MODE=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      show_help 
      exit 1
      ;;
    *) # only a single option is supported 
      PARAMS="$1"
      shift
      ;;	    
  esac
done

case "$PARAMS" in
  "stop")
    stop_docker_container
    echo "Server has stopped." 
    exit 0
    ;;
  "start")
    start_docker_container
    echo "Server has started."
    ;;
  "build")
    build_docker_image
    echo "Docker image has been rebuilt."
    ;;
  *)
    if [[ ! -z "$PARAMS" ]]; then
      show_help
      exit 1
    fi
    ;;
esac

if [ -z "$PARAMS" ] && [ -z "$MODE" ]; then
  show_help
  exit 1
fi	

if [ -z "$MODE" ]; then
  exit 0
fi	

case "$MODE" in
  "nlu")
    run_nlu
    ;;
  "train")
    run_train
    ;;
  "interactive")
    run_interactive
    ;;
  *)
    show_help
    exit 1
    ;;
esac;

