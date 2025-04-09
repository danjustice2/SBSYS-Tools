# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define the path to the executable and parameters
$exePath = "C:\Windows\System32\wscript.exe"
$parameters = '"C:\Program Files\SBSYS\SBSYS.vbs" "\\srafil01v\prog\SBSYS\SBSYSstarter\SBSYS.INI" "SbSysDrift"'
$sbsysExePath = "C:\Program Files\SBSYS\SbSysDrift\Sbsys.Windows.Client.exe"

# Get the process name from the executable path
$processName = [System.IO.Path]::GetFileNameWithoutExtension($sbsysExePath)

# Check if the process is already running
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process -eq $null) {
    # Process is not running, start the executable with parameters
    Start-Process $exePath -ArgumentList $parameters
} else {
    # Process is already running, show a popup message with options
    $result = [System.Windows.Forms.MessageBox]::Show("SBSYS k