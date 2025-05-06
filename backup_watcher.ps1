# backup_watcher.ps1

# Define the source folder to monitor
$sourceFolder = "C:\Users\$env:USERNAME\AppData\Roaming\Dokumenter\SbsysNetDrift\Kladde\$env:USERNAME"

# Define the backup root folder
$backupRoot = "C:\Users\$env:USERNAME\AppData\Roaming\Dokumenter\SbsysNetDrift\Kladde\$env:USERNAME.backup"

$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
# Define the log file path
$logFile = "C:\Users\$env:USERNAME\AppData\Roaming\Dokumenter\SbsysNetDrift\Kladde\backup_watcher-$timestamp.log"

# Path to the SBSYS application executable
$sbsysExePath = "C:\Program Files\SBSYS\SbSysDrift\Sbsys.Windows.Client.exe"

# Get the process name from the SBSYS executable path
$processName = [System.IO.Path]::GetFileNameWithoutExtension($sbsysExePath)

if (!(Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile -Force | Out-Null
}

# Function to log messages
function LogMessage($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $message"
    Write-Host $logEntry
    # Add-Content -Path $logFile -Value $logEntry
}

# Create a FileSystemWatcher object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourceFolder
$watcher.IncludeSubdirectories = $false
$watcher.Filter = "*.*"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, CreationTime'

# Function to handle file backup
function BackupFile($filePath) {
    Start-Sleep -Seconds 1 # Wait briefly in case the file is locked

    if (Test-Path $filePath) {
        # Exclude files starting with ~
        $fileName = [System.IO.Path]::GetFileName($filePath)
        if ($fileName.StartsWith("~")) {
            LogMessage "Skipping backup for temporary file: $filePath"
            return
        }

        try {
            LogMessage "Starting backup for file: $filePath"

            # Extract file details
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
            $extension = [System.IO.Path]::GetExtension($filePath)
            # Prepare date/time subfolders in Danish
            $now = Get-Date
            $monthNames = @("januar", "februar", "marts", "april", "maj", "juni", "juli", "august", "september", "oktober", "november", "december")
            $month = $monthNames[$now.Month - 1]
            $day = $now.ToString("dd")
            $dayWithMonth = "$day. $month"
            $hour = $now.ToString("HH")
            $minute = $now.ToString("mm")
            $second = $now.ToString("ss")

            # Build the backup directory path
            $backupDir = Join-Path $backupRoot "$month\$dayWithMonth\kl. $hour\$baseName"

            # Create the directory if it doesn't exist
            if (!(Test-Path $backupDir)) {
                LogMessage "Creating backup directory: $backupDir"
                New-Item -ItemType Directory -Path $backupDir | Out-Null
            }

            # Generate a UUID
            $uuid = [guid]::NewGuid().ToString()

            # Create a timestamped and unique file name
            $timestamp = "$hour-$minute-$second"
            $uniqueFileName = "$baseName-$timestamp----$uuid$extension"

            # Copy the file to the backup directory
            $destFile = Join-Path $backupDir $uniqueFileName
            Copy-Item -Path $filePath -Destination $destFile -Force

            LogMessage "File backed up successfully: $destFile"
        } catch {
            LogMessage "Error backing up file: $filePath. $_"
        }
    } else {
        LogMessage "File not found: $filePath"
    }
}

# Event handler for Created event
$handlerCreated = Register-ObjectEvent -InputObject $watcher -EventName Created -Action {
    param($sender, $eventArgs)
    LogMessage "File created: $($eventArgs.FullPath)"
    BackupFile $eventArgs.FullPath
}

# Event handler for Changed event
$handlerChanged = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action {
    param($sender, $eventArgs)
    LogMessage "File changed: $($eventArgs.FullPath)"
    BackupFile $eventArgs.FullPath
}

# Enable the FileSystemWatcher
$watcher.EnableRaisingEvents = $true

# Log startup message
LogMessage "Backup watcher started. Monitoring folder: $sourceFolder"

# Determine the desktop path dynamically
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Define the shortcut path and target folder
$shortcutPath = Join-Path $desktopPath "SBSYS Kladde Backup.lnk"
$targetFolder = "C:\Users\$env:USERNAME\AppData\Roaming\Dokumenter\SbsysNetDrift\Kladde\$env:USERNAME.backup"

# Check if the shortcut already exists
if (!(Test-Path $shortcutPath)) {
    # Create the shortcut
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetFolder
    $shortcut.WorkingDirectory = $targetFolder
    $shortcut.WindowStyle = 1
    $shortcut.IconLocation = "shell32.dll, 3"  # Default folder icon
    $shortcut.Save()

    LogMessage "Shortcut created on desktop: $shortcutPath"
} else {
    LogMessage "Shortcut already exists on desktop: $shortcutPath"
}

# Keep the script running
Write-Host "Backup watcher started. Press Ctrl+C to stop."
while ($true) {
    
    Start-Sleep -Seconds 10
    # Check if the process is running
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($null -eq $processes) {
        LogMessage "Process $processName is not running. Stopping the script."
        break
    }
    LogMessage "Watching for changes in $sourceFolder..."
}
