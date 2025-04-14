$backupRoot = "C:\Users\$env:USERNAME\AppData\Roaming\Dokumenter\SbsysNetDrift\Kladde\$env:USERNAME.backup"
$cutoffDate = (Get-Date).AddDays(-7)

# Remove old files
Get-ChildItem -Path $backupRoot -Recurse -File | ForEach-Object {
    if ($_.LastWriteTime -lt $cutoffDate) {
        Remove-Item $_.FullName -Force
    }
}

# Remove empty folders
Get-ChildItem -Path $backupRoot -Recurse -Directory | ForEach-Object {
    if (-not (Get-ChildItem -Path $_.FullName)) {
        Remove-Item $_.FullName -Force -Recurse
    }
}