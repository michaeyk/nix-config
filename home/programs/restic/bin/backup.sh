#!/bin/bash

# Get the system hostname
HOSTNAME=$(hostname)
BACKUP_REPO="/mnt/mike/backup/${HOSTNAME}"

notify-send "Restic backup started."
echo "Removing old locks ..."
restic unlock \
        -r "$BACKUP_REPO" \
        --password-file <( gpg --decrypt $HOME/.password-store/general/restic.gpg )

echo "Creating incremental backup ..."
### Backup new stuff
restic backup \
        -r "$BACKUP_REPO" \
        --password-file <( gpg --decrypt $HOME/.password-store/general/restic.gpg ) \
        --verbose \
        --files-from /home/mike/.config/restic/backup.files \
        --exclude-file /home/mike/.config/restic/exclude.files

### Remove old stuff
echo "Deleting old backups ..."
restic forget \
        -r "$BACKUP_REPO" \
        --password-file <( gpg --decrypt $HOME/.password-store/general/restic.gpg ) \
        --keep-last 7 \
        --keep-daily 14 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        --prune

# restic -r $BACKARCH check
echo "Don't forget to run \"restic check\" from time to time"
echo "Backup finished."
notify-send "Restic backup finished."
