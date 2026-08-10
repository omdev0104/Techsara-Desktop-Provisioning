function Invoke-Installer
{
    param(
        [Parameter(Mandatory)]
        $App,

        [Parameter(Mandatory)]
        [string]$Installer,

        [Parameter(Mandatory)]
        [bool]$DevelopmentMode
    )

    Write-DeployLog "--------------------------------------------"
    Write-DeployLog "Application : $($App.Name)"
    Write-DeployLog "Installer   : $Installer"

    if ($DevelopmentMode)
    {
        Write-DeployLog "Mode        : DEVELOPMENT"
        Write-DeployLog "Method      : $($App.InstallMethod)"
        Write-DeployLog "Arguments   : $($App.Arguments)"
        Write-DeployLog "[DEV] Installation skipped."

        return
    }

    try
    {
        switch ($App.InstallMethod)
        {
            "StartProcess"
            {
                Write-DeployLog "Launching installer..."

                $process = Start-Process `
                    -FilePath $Installer `
                    -ArgumentList $App.Arguments `
                    -Wait `
                    -PassThru

                if ($process.ExitCode -eq 0)
                {
                    Write-DeployLog "$($App.Name) installed successfully."
                }
                else
                {
                    Write-DeployLog "$($App.Name) exited with code $($process.ExitCode)." "ERROR"
                }
            }

            "Appx"
            {
                Write-DeployLog "Installing MSIX package..."

                Add-AppxPackage $Installer

                Write-DeployLog "$($App.Name) installed successfully."
            }

            default
            {
                Write-DeployLog "Unknown installation method: $($App.InstallMethod)" "ERROR"
            }
        }
    }
    catch
    {
        Write-DeployLog "$($App.Name) installation failed." "ERROR"
        Write-DeployLog $_.Exception.Message "ERROR"
    }

    Write-DeployLog "--------------------------------------------"
}