# Available on Github at: https://github.com/danjustice2/SBSYS-only-one-instance

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define the path to the executable and parameters
$exePath = "C:\Windows\System32\wscript.exe"
$parameters = '"C:\Program Files\SBSYS\SBSYS.vbs" "\\srafil01v\prog\SBSYS\SBSYSstarter\SBSYS.INI" "SbSysDrift"'
$sbsysExePath = "C:\Program Files\SBSYS\SbSysDrift\Sbsys.Windows.Client.exe"

# Get the process name from the executable path
$processName = [System.IO.Path]::GetFileNameWithoutExtension($sbsysExePath)

# Define a path to store the timestamp of the last run
$timestampFile = "$env:Temp\SBSYS_LastRun.txt"

# Check if the timestamp file exists and read the last run time
if (Test-Path $timestampFile) {
    $lastRunTimeString = Get-Content $timestampFile | Out-String | ForEach-Object { $_.Trim() }
    $lastRunTime = [datetime]$lastRunTimeString
    $currentTime = Get-Date

    # If the script was run less than 5 seconds ago, exit
    if (($currentTime - $lastRunTime).TotalSeconds -lt 5) {
        return
    }
}

# Update the timestamp file with the current time
(Get-Date).ToString("o") | Set-Content $timestampFile

# Check if the process is already running
$processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($null -eq $processes) {
    # Process is not running, start the executable with parameters
    Start-Process $exePath -ArgumentList $parameters
} elseif ($processes.Count -gt 1) {
    # Multiple instances detected, show a popup message
    [System.Windows.Forms.MessageBox]::Show("Du har allerede mere end én SBSYS-instans kørende. Du anbefales kun at have én kopi af SBSYS kørende ad gangen for at undgå datatab.", "Advarsel", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
} else {
    # Single instance detected, show a popup message
    [System.Windows.Forms.MessageBox]::Show("SBSYS kører allerede.", "Advarsel", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
}