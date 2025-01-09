#!/bin/bash

# Get today's date for our backup filename
backupDate=$(date +'%F')
USERDIR="/home/char"
REMOTEDIR="Penguin"
STATUS_FILE=".service_status" # File to track enabled/disabled services

is_disabled() {
  grep -q "^$1:disabled$" "$STATUS_FILE"
}

composeUpDown() {
  for f in *; do
    if [ -d "$f" ]; then
      # Check if the docker-compose.yaml file exists in the subdirectory
      if [ -f "$f/docker-compose.yaml" ]; then
        if is_disabled "$f"; then
          echo "Service $f is disabled. Skipping..."
          continue
        fi
        echo -n "Service $f "

        # Run the appropriate Docker Compose command
        if [ "$1" = "start" ]; then
          (echo "Starting..." && docker compose -f "$f"/docker-compose.yaml up -d)
        elif [ "$1" = "stop" ]; then
          (echo "Stoping..." && docker compose -f "$f"/docker-compose.yaml down)
        fi
      else
        echo "No docker-compose.yaml found in $f, skipping..."
      fi
    fi
  done
}

# move to the path where you will keep all of yoru docker configurations and data
cd "$USERDIR/containers" || exit 1
composeUpDown stop

# move back to your home directory and create a tar archive of your docker parent folder
cd "$USERDIR" || exit 1
tar -czf docker-backup-"$backupDate".tar.gz containers

# now go back to home, and copy my backup file to my NAS
cd "$USERDIR" || exit 1
echo ""
echo "Backup copy is uploading..."

# use secure copy to copy the tar archive to your final backup location (in my case a mounted NFS share)
rclone copyto docker-backup-"$backupDate".tar.gz "drive:$REMOTEDIR/docker-backup-$backupDate.tar.gz"
rclone lsf "drive:$REMOTEDIR" | sort | head -n -5 | while read -r oldfile; do
  if [ -n "$oldfile" ]; then
    echo "Would delete drive:$REMOTEDIR/$oldfile"
    rclone delete "drive:$REMOTEDIR/$oldfile"
  fi
done

# remove the tar file from the main home folder after it's copied
rm docker-backup-"$backupDate".tar.gz

cd "$USERDIR/containers" || exit 1
composeUpDown start
