#!/bin/bash

# Get the system hostname
HOSTNAME=$(hostname)
BACKUP_REPO="/mnt/mike/backup/${HOSTNAME}"

# Skip if backup server is unreachable — otherwise restic wedges on the NFS
# automount and can block nixos-rebuild via dependent units.
if ! timeout 3 bash -c '</dev/tcp/10.253.0.1/2049' 2>/dev/null; then
    echo "Backup server 10.253.0.1 unreachable, skipping backup."
    notify-send "Restic backup skipped (server offline)." 2>/dev/null || true
    exit 0
fi

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
