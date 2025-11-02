# PHP_drive_sync


A lightweight PHP + Bash system for comparing and syncing local folders with Google Drive using `rclone`. Designed for home servers running DietPi or Ubuntu

---

## 🚀 Features

- Compare local and remote folders
- Detect missing files on either side
- Sync missing files (upload/download)
- Web dashboard with folder selection
- Timestamped logs of all operations

---

## 📦 Folder Structure

/usr/local/bin/compare_drive.sh # Bash script for compare/sync 
/var/www/html/compare.php # Web dashboard 
/var/www/files/dietpi_userdata/DRIVE_AD/ # Root folder for sync -> TO BE UPDATED
/var/www/files/tmp/folder_comparison.log # Log output

---

## 🖥️ Web Dashboard

The PHP dashboard (`compare.php`) lets you:

- Select a subfolder from `DRIVE_AD`
- Compare it with the matching Google Drive folder
- View missing files
- Trigger sync operations
- View logs in real time

---

## 🔧 Bash Script Usage

```bash
# Compare only
sudo /usr/local/bin/compare_drive.sh compare FOLDER_NAME
```
# Compare and sync

🛠️ Requirements
rclone configured with Google Drive remote
