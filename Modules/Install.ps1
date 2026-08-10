function Install-Application
{
    param(
        [Parameter(Mandatory)]
        $App,

        [Parameter(Mandatory)]
        [string]$ServerPath,

        [Parameter(Mandatory)]
        [bool]$DevelopmentMode
    )

    Write-DeployLog "Preparing $($App.Name)"

    # Build full installer path
    $Installer = Join-Path $ServerPath $App.File

    # Verify installer exists
    if (!(Test-Path $Installer))
    {
        Write-DeployLog "$($App.Name) installer not found." "ERROR"
        return
    }

    Write-DeployLog "Installer located."

    # Skip disabled applications
    if (-not $App.Enabled)
    {
        Write-DeployLog "$($App.Name) is disabled. Skipping."
        return
    }

    # Pass installation to installer engine
    Invoke-Installer `
        -App $App `
        -Installer $Installer `
        -DevelopmentMode $DevelopmentMode
}