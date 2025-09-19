#!/bin/bash
set -u
# Check if an argument is passed
if [ "$#" -lt 1 ]; then
	echo "Usage: $0 [up|down|list|restart|enable|disable|update]"
	exit 1
fi

# Assign the command based on the argument
COMMAND=$1

if [ "$COMMAND" == "enable" ]; then
	echo "Enabling service $2..."
	mv disabled/"$2" . || echo "Failed to enable service in $2." >&2
elif [ "$COMMAND" == "disable" ]; then
	echo "Disabling service $2..."
	# rm -rf "$f"/data || echo "Failed to delete data folder in $f." >&2
	mv "$2" disabled || echo "Failed to disable service in $2." >&2
fi

# Loop through all subdirectories
for f in *; do
	if [ -d "$f" ]; then
		# Validate the argument
		case "$COMMAND" in
		list)
			if [ "$f" == "disabled" ]; then
				find "$f" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
			else
				echo "$f"
			fi
			;;
		up | down | restart | update)
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
				up)
					echo "Starting service in $f..."
          if [ ! -d "$f/data" ]; then
            mkdir -p "$f"/data
          fi
					docker compose -f "$f/docker-compose.yaml" up -d || echo "Failed to start service in $f." >&2
					;;
				down)
					echo "Stopping service in $f..."
					docker compose -f "$f/docker-compose.yaml" down || echo "Failed to stop service in $f." >&2
					;;
				restart)
					echo "Restarting service in $f..."
					docker compose -f "$f/docker-compose.yaml" down || echo "Failed to stop service in $f." >&2
					docker compose -f "$f/docker-compose.yaml" up -d || echo "Failed to start service in $f." >&2
					;;
        update)
					echo "Stopping service in $f..."
					docker compose -f "$f/docker-compose.yaml" pull || echo "Failed to pull service update in $f." >&2
          # docker compose -f "$f/docker-compose.yaml" up -d || echo "Failed to start service in $f." >&2
					;;
				esac

			else
				echo "skipping $f..."
			fi
			;;
		enable | disable) ;;
		*)
			echo "Invalid command: $COMMAND"
			exit 1
			;;
		esac
	fi
done
