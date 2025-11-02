#!/bin/bash

export HOME="/tmp"

ACTION="$1"  # "compare" or "sync"
FOLDER="$2"  # subfolder name
BASE="/var/www/files/dietpi_userdata/DRIVE_AD" #CHANGE WITH YOUR OWN PATH TO DRIVE BACKUP HERE
LOCAL_DIR="$BASE/$FOLDER"
REMOTE="gdrive:$FOLDER"
TMP_DIR="/var/www/files/tmp"
LOG_FILE="$TMP_DIR/folder_comparison.log"

TMP_LOCAL="$TMP_DIR/local_files.txt"
TMP_REMOTE="$TMP_DIR/remote_files.txt"

# === Start Log ===
echo "=== Folder Comparison Started ===" > "$LOG_FILE"
echo "Local: $LOCAL_DIR" >> "$LOG_FILE"
echo "Remote: $REMOTE" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# === Generate File Lists ===
find "$LOCAL_DIR" -type f -printf "%P\n" | sort -u > "$TMP_LOCAL"
rclone --config=/etc/rclone.conf lsf "$REMOTE" --files-only --recursive | sed 's|/*$||' | sort -u > "$TMP_REMOTE"

# === Compare ===
echo "=== Missing on Google Drive ===" >> "$LOG_FILE"
comm -23 "$TMP_LOCAL" "$TMP_REMOTE" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "=== Missing Locally ===" >> "$LOG_FILE"
comm -13 "$TMP_LOCAL" "$TMP_REMOTE" >> "$LOG_FILE"

# === Sync if Requested ===
if [ "$ACTION" = "sync" ]; then
    echo "" >> "$LOG_FILE"
    echo "=== Syncing Missing Files ===" >> "$LOG_FILE"

    # Upload missing files to Drive
    comm -23 "$TMP_LOCAL" "$TMP_REMOTE" | while read -r file; do
        SRC="$LOCAL_DIR/$file"
        DEST="$REMOTE/$file"
        rclone --config=/etc/rclone.conf copyto "$SRC" "$DEST"
        echo "Uploaded: $file" >> "$LOG_FILE"
    done

    # Download missing files from Drive
    comm -13 "$TMP_LOCAL" "$TMP_REMOTE" | while read -r file; do
        SRC="$REMOTE/$file"
        DEST="$LOCAL_DIR/$file"
        mkdir -p "$(dirname "$DEST")"
        rclone --config=/etc/rclone.conf copyto "$SRC" "$DEST"
        echo "Downloaded: $file" >> "$LOG_FILE"
    done
fi

echo "" >> "$LOG_FILE"
echo "=== Operation Complete ===" >> "$LOG_FILE"
