#!/bin/bash

# Check if an argument is passed
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [start|stop|list|restart]"
  exit 1
fi

# Assign the command (start or stop) based on the argument
COMMAND=$1

# Validate the argument
if [ "$COMMAND" != "start" ] && [ "$COMMAND" != "stop" ] && [ "$COMMAND" != "list" ] && [ "$COMMAND" != "restart" ]; then
  echo "Invalid argument: $COMMAND. Use 'start' or 'stop'."
  exit 1
fi

# Check if the Docker network 'proxy' exists
if [! docker network inspect proxy >/dev/null 2>&1] && [ -f "traefik/docker-compose.yaml" ]; then
  echo "Docker network 'proxy' does not exist. Creating it..."
  docker network create proxy
  if [ $? -ne 0 ]; then
    echo "Failed to create Docker network 'proxy'. Exiting..." >&2
    exit 1
  fi
else
  echo "Docker network 'proxy' already exists. Continuing..."
fi

# Loop through all subdirectories
for f in *; do
  if [ -d "$f" ]; then
    # Check if the docker-compose.yaml file exists in the subdirectory
    if [ -f "$f/docker-compose.yaml" ]; then
      echo -n "Service $f "

      # Run the appropriate Docker Compose command
      if [ "$COMMAND" = "start" ]; then
        (echo "Starting..." && docker compose -f $f/docker-compose.yaml up -d)
      elif [ "$COMMAND" = "stop" ]; then
        (echo "Stoping..." && docker compose -f $f/docker-compose.yaml down)
      elif [ "$COMMAND" = "restart" ]; then
        (echo "Restarting..." && docker compose -f $f/docker-compose.yaml down && docker compose -f $f/docker-compose.yaml up -d)
      else
        echo ""
      fi
    else
      echo "No docker-compose.yaml found in $f, skipping..."
    fi
  fi
done
