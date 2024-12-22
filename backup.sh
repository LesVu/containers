#!/bin/bash

# Get today's date for our backup filename
backupDate=$(date +'%F')
userDir="/home/char"
remoteDir="Penguin"

composeUpDown() {
  for f in *; do
    if [ -d "$f" ]; then
      # Check if the docker-compose.yaml file exists in the subdirectory
      if [ -f "$f/docker-compose.yaml" ]; then
        echo -n "Service $f "

        # Run the appropriate Docker Compose command
        if [ "$1" = "start" ]; then
          (echo "Starting..." && docker compose -f $f/docker-compose.yaml up -d)
        elif [ "$1" = "stop" ]; then
          (echo "Stoping..." && docker compose -f $f/docker-compose.yaml down)
        fi
      else
        echo "No docker-compose.yaml found in $f, skipping..."
      fi
    fi
  done
}

# move to the path where you will keep all of yoru docker configurations and data
cd "$userDir/containers"
composeUpDown stop

# move back to your home directory and create a tar archive of your docker parent folder
cd "$userDir"
tar -czf docker-backup-$backupDate.tar.gz containers

# now go back to home, and copy my backup file to my NAS
cd "$userDir"
echo ""
echo "Backup copy is running..."

# use secure copy to copy the tar archive to your final backup location (in my case a mounted NFS share)
rclone copyto containers-backup-$backupDate.tar.gz "drive:$remoteDir/docker-backup-$backupDate.tar.gz"
rclone lsf "drive:$remoteDir" | sort | head -n -5 | while read oldfile; do
  if [ -n "$oldfile" ]; then
    echo "Would delete drive:$remoteDir/$oldfile"
    rclone delete "drive:$remoteDir/$oldfile"
  fi
done

# remove the tar file from the main home folder after it's copied
rm docker-backup-$backupDate.tar.gz

cd "$userDir/containers"
composeUpDown start
