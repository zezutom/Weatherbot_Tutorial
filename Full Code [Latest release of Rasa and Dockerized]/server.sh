#!/bin/bash
set +x
RASA_CONFIG_DIR="config/rasa/"
MODEL_NAME="weather_model"

run_help() {
  echo "Usage: server.sh -m | --model (nlu | train | interactive) [-b | --build]"
}

run_build() {
  docker build . -t rasa/weatherbot
}

run_nlu() {
  echo "nlu mode!"
}

run_train() {
  echo "training"
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

RUN_BUILD=false
while (( "$#" )); do
  case "$1" in
    -n|--nlu)
      MODE="nlu"
      shift 2
      ;;
    -t|--train)
      MODE="train"
      shift 2
      ;;
    -i|--interactive)
      MODE="interactive"
      shift 2
      ;;
    -b|--build)
      RUN_BUILD=true 
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    *) # unsupported flags
      run_help 
      exit 1
      ;;
  esac
done

if "$RUN_BUILD"; then
  run_build
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
    echo "Mode must be one of: nlu | train | interactive" 
esac;

