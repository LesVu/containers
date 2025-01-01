#!/bin/bash

# Check if an argument is passed
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [start|stop|list|restart|enable|disable|status]"
  exit 1
fi

# Assign the command based on the argument
COMMAND=$1
STATUS_FILE=".service_status" # File to track enabled/disabled services

# Validate the argument
if [[ "$COMMAND" != "start" && "$COMMAND" != "stop" && "$COMMAND" != "list" && "$COMMAND" != "restart" && "$COMMAND" != "enable" && "$COMMAND" != "disable" && "$COMMAND" != "status" ]]; then
  echo "Invalid argument: $COMMAND. Use 'start', 'stop', 'list', 'restart', 'enable', 'disable', or 'status'."
  exit 1
fi

# Ensure the status file exists
if [ ! -f "$STATUS_FILE" ]; then
  touch "$STATUS_FILE"
fi

# Function to check if a service is disabled
is_disabled() {
  grep -q "^$1:disabled$" "$STATUS_FILE"
}

# Function to update service status
update_status() {
  local service=$1
  local status=$2
  sed -i "/^$service:/d" "$STATUS_FILE" # Remove existing entry
  echo "$service:$status" >>"$STATUS_FILE"
}

# Handle the 'enable' and 'disable' commands
if [[ "$COMMAND" == "enable" || "$COMMAND" == "disable" ]]; then
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 $COMMAND <service_directory>"
    exit 1
  fi

  SERVICE=$2

  if [ ! -d "$SERVICE" ]; then
    echo "Service directory $SERVICE does not exist."
    exit 1
  fi

  if [ ! -f "$SERVICE/docker-compose.yaml" ]; then
    echo "No docker-compose.yaml found in $SERVICE."
    exit 1
  fi

  if [ "$COMMAND" == "enable" ]; then
    update_status "$SERVICE" "enabled"
    echo "Service $SERVICE is now enabled."
  else
    update_status "$SERVICE" "disabled"
    echo "Service $SERVICE is now disabled."
  fi

  exit 0
fi

# Handle the 'status' command
if [ "$COMMAND" == "status" ]; then
  echo "Service Status:"
  if [ -s "$STATUS_FILE" ]; then
    cat "$STATUS_FILE"
  else
    echo "No services have been enabled or disabled yet."
  fi
  exit 0
fi

# Check if the Docker network 'proxy' exists
if ! docker network inspect proxy >/dev/null 2>&1; then
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
      # Check if the service is disabled
      if is_disabled "$f"; then
        echo "Service $f is disabled. Skipping..."
        continue
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
        list)
          echo "Listing services for $f:"
          docker compose -f "$f/docker-compose.yaml" ps || echo "Failed to list services in $f." >&2
          ;;
      esac

    else
      echo "No docker-compose.yaml found in $f, skipping..."
    fi
  fi
done
