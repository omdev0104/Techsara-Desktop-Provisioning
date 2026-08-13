# Techsara Desktop Provisioning Utility - Application Installation Module

function Install-Application {
    param(
        [Parameter(Mandatory)] $App,
        [Parameter(Mandatory)] [string]$ServerPath,
        [Parameter(Mandatory)] [bool]$DevelopmentMode
    )

    Write-DeployLog "Preparing $($App.Name)"
    $Installer = Join-Path $ServerPath $App.File
    Write-DeployLog "Installer path: $Installer"

    if (-not (Test-Path -LiteralPath $Installer)) {
        Write-DeployLog "$($App.Name) installer not found." "ERROR"
        return $false
    }

    Write-DeployLog "Installer located."

    if (-not $App.Enabled) {
        Write-DeployLog "$($App.Name) is disabled. Skipping."
        return $true
    }

    try {
        return [bool](Invoke-Installer -App $App -Installer $Installer -DevelopmentMode $DevelopmentMode)
    } catch {
        Write-DeployLog "$($App.Name) installation wrapper failed." "ERROR"
        Write-DeployLog $_.Exception.Message "ERROR"
        return $false
    }
}
