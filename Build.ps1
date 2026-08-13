# ==========================================
# Techsara Desktop Provisioning Utility
# Version 0.3
# ==========================================

Clear-Host

# ==========================================
# Import Modules
# ==========================================

. "$PSScriptRoot\Modules\Logger.ps1"
. "$PSScriptRoot\Modules\Network.ps1"
. "$PSScriptRoot\Modules\InstallerEngine.ps1"
. "$PSScriptRoot\Modules\Install.ps1"
. "$PSScriptRoot\Modules\UI.ps1"
. "$PSScriptRoot\Modules\DeploymentManager.ps1"

Write-Host ""
Write-Host "==============================================="
Write-Host "     Techsara Desktop Provisioning Utility"
Write-Host "==============================================="
Write-Host ""

# ==========================================
# Load Configuration
# ==========================================

$configPath = Join-Path $PSScriptRoot "Config\Apps.json"

if (!(Test-Path $configPath))
{
    Write-Host "Apps.json not found." -ForegroundColor Red
    exit
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json

Write-DeployLog "Configuration Loaded"
Write-DeployLog "Version : $($config.Settings.Version)"

# ==========================================
# Development Mode
# ==========================================

$DevelopmentMode = $config.Settings.DevelopmentMode

if ($DevelopmentMode)
{
    Write-DeployLog "Running in DEVELOPMENT MODE"
}
else
{
    Write-DeployLog "Running in PRODUCTION MODE"
}

# ==========================================
# Build Server Path
# ==========================================

$ServerPath = "\\$($config.Server.Host)\$($config.Server.Share)\$($config.Server.Folder)"

Write-DeployLog "Deployment Server : $ServerPath"

# ==========================================
# Test Server
# ==========================================

if (!(Test-DeploymentServer -Server $ServerPath))
{
    Write-DeployLog "Deployment Aborted." "ERROR"

    Add-Type -AssemblyName System.Windows.Forms

    [System.Windows.Forms.MessageBox]::Show(
        "Unable to connect to the deployment server.",
        "Connection Failed"
    )

    exit
}

Write-DeployLog "Server validation completed."

# ==========================================
# Launch GUI
# ==========================================

Show-MainWindow -DevelopmentMode $DevelopmentMode

Write-DeployLog "Application Closed."