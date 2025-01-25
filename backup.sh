#!/bin/bash

# Get today's date for our backup filename
backupDate=$(date +'%F')
USERDIR="/home/char"
REMOTEDIR="Penguin"

composeUpDown() {
  for f in *; do
    # Check if the docker-compose.yaml file exists in the subdirectory
    if [ -d "$f" ] && [ -f "$f/docker-compose.yaml" ] && [ "$f" != "disabled" ]; then
      echo -n "Service $f "

      # Run the appropriate Docker Compose command
      if [ "$1" = "start" ]; then
        (echo "starting..." && docker compose -f "$f"/docker-compose.yaml start)
      elif [ "$1" = "stop" ]; then
        (echo "stoping..." && docker compose -f "$f"/docker-compose.yaml stop)
      fi
    fi
  done
}

# move to the path where you will keep all of yoru docker configurations and data
cd "$USERDIR/containers" || exit 1
composeUpDown stop

# move back to your home directory and create a tar archive of your docker parent folder
cd "$USERDIR" || exit 1
sudo tar -czf docker-backup-"$backupDate".tar.gz containers

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
sudo rm docker-backup-"$backupDate".tar.gz

cd "$USERDIR/containers" || exit 1
composeUpDown start
