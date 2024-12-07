#!/bin/bash

# Check if an argument is passed
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [start|stop|list]"
  exit 1
fi

# Assign the command (start or stop) based on the argument
COMMAND=$1

# Validate the argument
if [ "$COMMAND" != "start" ] && [ "$COMMAND" != "stop" ] && [ "$COMMAND" != "list" ]; then
  echo "Invalid argument: $COMMAND. Use 'start' or 'stop'."
  exit 1
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
      else
        echo ""
      fi
    else
      echo "No docker-compose.yaml found in $f, skipping..."
    fi
  fi
done
