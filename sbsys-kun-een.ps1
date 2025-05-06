ï»¿# Available on Github at: https://github.com/danjustice2/SBSYS-Tools

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# ============================
# CONFIGURATION SECTION
# ============================

# Path to the executable that launches the SBSYS application
$exePath = "C:\Windows\System32\wscript.exe"

# Parameters to pass to the executable
# Update the paths below to match your SBSYS environment
$parameters = '"C:\Program Files\SBSYS\SBSYS.vbs" "\\srafil01v\prog\SBSYS\SBSYSstarter\SBSYS.INI" "SbSysDrift"'

# Path to the SBSYS application executable
$sbsysExePath = "C:\Program Files\SBSYS\SbSysDrift\Sbsys.Windows.Client.exe"

# Path to store the timestamp of the last run
# You can change this if needed, but the default is the Temp folder
$timestampFile = "$env:Temp\SBSYS_LastRun.txt"

# Time interval (in seconds) to prevent the script from running multiple times in quick succession
$minimumIntervalSeconds = 5

# ============================
# SCRIPT LOGIC
# ============================

# Get the process name from the SBSYS executable path
$processName = [System.IO.Path]::GetFileNameWithoutExtension($sbsysExePath)

# Check if the timestamp file exists and read the last run time
if (Test-Path $timestampFile) {
    $lastRunTimeString = Get-Content $timestampFile | Out-String | ForEach-Object { $_.Trim() }
    $lastRunTime = [datetime]$lastRunTimeString
    $currentTime = Get-Date

    # If the script was run less than the minimum interval ago, exit
    if (($currentTime - $lastRunTime).TotalSeconds -lt $minimumIntervalSeconds) {
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

    # Check if an additional script path is provided as an input parameter
    if ($args.Count -gt 0) {
        $additionalScriptPath = $args[0]

        # Validate if the provided script path exists
        if (Test-Path $additionalScriptPath) {
            # Run the additional script as a hidden background process
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$additionalScriptPath`"" -WindowStyle Hidden
        }
        }
    }
elseif ($processes.Count -gt 1) {
    # Multiple instances detected, show a popup message
    [System.Windows.Forms.MessageBox]::Show("Du har allerede mere end Ã©n SBSYS-instans kÃ¸rende. Du anbefales kun at have Ã©n kopi af SBSYS kÃ¸rende ad gangen for at undgÃ¥ datatab.", "Advarsel", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
} else {
    # Single instance detected, show a popup message
    [System.Windows.Forms.MessageBox]::Show("SBSYS kÃ¸rer allerede. Hvis du ikke kan finde SBSYS-vinduet bedes du genstarte din computer og prÃ¸ve igen.", "Advarsel", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
}
