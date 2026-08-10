function Write-DeployLog
{
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $LogFolder = Join-Path $PSScriptRoot "..\Logs"

    if(!(Test-Path $LogFolder))
    {
        New-Item -ItemType Directory -Path $LogFolder | Out-Null
    }

    $LogFile = Join-Path $LogFolder "$(Get-Date -Format 'yyyy-MM-dd').log"

    $Time = Get-Date -Format "HH:mm:ss"

    $Entry = "[$Time] [$Level] $Message"

    Add-Content -Path $LogFile -Value $Entry

    Write-Host $Entry
}