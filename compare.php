<?php
$logFile = "/var/www/files/tmp/folder_comparison.log";
$basePath = "/var/www/files/dietpi_userdata/DRIVE_AD";
$log = '';
$selectedFolder = $_POST['folder'] ?? '';

// Get subfolders
$folders = array_filter(glob("$basePath/*"), 'is_dir');
$folderNames = array_map('basename', $folders);
sort($folderNames);

if (!empty($selectedFolder) && (isset($_POST['compare']) || isset($_POST['sync']))) {
    $action = isset($_POST['sync']) ? "sync" : "compare";
    $escapedAction = escapeshellarg($action);
    $escapedFolder = escapeshellarg($selectedFolder);

    // Clear old log
    if (file_exists($logFile)) {
        file_put_contents($logFile, "");
    }

    // Run the script with action and folder
    shell_exec("sudo /usr/local/bin/compare_drive.sh $escapedAction $escapedFolder > /dev/null 2>&1");

    if (file_exists($logFile) && is_readable($logFile)) {
        $log = file_get_contents($logFile);
    } else {
        $log = "Log file not found or not readable.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Folder Sync</title>
    <style>
        body { font-family: monospace; background: #f4f4f4; padding: 20px; }
        textarea { width: 100%; height: 400px; }
        select, button { padding: 10px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <h2>Compare & Sync Folder with Google Drive</h2>
    <form method="post">
        <label>Select Folder:</label><br>
        <select name="folder" required>
            <option value="">-- Choose a folder --</option>
            <?php foreach ($folderNames as $folder): ?>
                <option value="<?= htmlspecialchars($folder) ?>" <?= $folder === $selectedFolder ? 'selected' : '' ?>>
                    <?= htmlspecialchars($folder) ?>
                </option>
            <?php endforeach; ?>
        </select><br>
        <button name="compare">Compare</button>
        <?php if (!empty($log)): ?>
            <button name="sync">Sync Missing Files</button>
        <?php endif; ?>
    </form>

    <?php if (!empty($log)): ?>
        <h3>Comparison Log:</h3>
        <textarea readonly><?= htmlspecialchars($log) ?></textarea>
    <?php endif; ?>
</body>
</html>
