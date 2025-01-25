#!/bin/bash

# Check if an argument is passed
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [start|stop|list|restart|enable|disable|status]"
  exit 1
fi

# Assign the command based on the argument
COMMAND=$1

# Validate the argument
if [[ "$COMMAND" != "start" && "$COMMAND" != "stop" && "$COMMAND" != "restart" ]]; then
  echo "Invalid argument: $COMMAND. Use 'start', 'stop', 'restart'."
  exit 1
fi

# Loop through all subdirectories
for f in *; do
  if [ -d "$f" ]; then
    # Check if the docker-compose.yaml file exists in the subdirectory
    if [[ -f "$f/docker-compose.yaml" && "$f" != "disabled" ]]; then
      if [[ "$f" == "proxy" || "$f" == "traefik" ]]; then
        # Check if the Docker network 'proxy' exists
        if ! docker network inspect proxy >/dev/null 2>&1; then
          echo "Docker network 'proxy' does not exist. Creating it..."
          if ! docker network create proxy; then
            echo "Failed to create Docker network 'proxy'. Exiting..." >&2
            exit 1
          fi
        fi
      fi

      echo "Processing service in directory: $f"

      case "$COMMAND" in
      start)
        echo "Starting service in $f..."
        docker compose -f "$f/docker-compose.yaml" up -d || echo "Failed to start service in $f." >&2
        ;;
      stop)
        echo "Stopping service in $f..."
        docker compose -f "$f/docker-compose.yaml" down || echo "Failed to stop service in $f." >&2
        ;;
      restart)
        echo "Restarting service in $f..."
        docker compose -f "$f/docker-compose.yaml" down || echo "Failed to stop service in $f." >&2
        docker compose -f "$f/docker-compose.yaml" up -d || echo "Failed to start service in $f." >&2
        ;;
      esac

    else
      echo "skipping $f..."
    fi
  fi
done
