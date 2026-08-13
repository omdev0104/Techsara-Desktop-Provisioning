# ==========================================
# Techsara Desktop Provisioning Utility
# Installer Engine
# ==========================================

function Invoke-Installer {

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
    Write-DeployLog "Method      : $($App.InstallMethod)"
    Write-DeployLog "Arguments   : $($App.Arguments)"


    # ==========================================
    # DEVELOPMENT MODE
    # ==========================================

    if ($DevelopmentMode) {

        Write-DeployLog "Mode        : DEVELOPMENT"
        Write-DeployLog "[DEV] Installation skipped."
        Write-DeployLog "--------------------------------------------"

        return $true
    }


    # ==========================================
    # PRODUCTION MODE
    # ==========================================

    try {

        switch ($App.InstallMethod) {


            # ==================================
            # EXE INSTALLER
            # ==================================

            "StartProcess" {

                Write-DeployLog "Mode        : PRODUCTION"
                Write-DeployLog "Launching installer..."


                # ----------------------------------
                # If Arguments is empty, launch the
                # installer without -ArgumentList.
                # ----------------------------------

                if (
                    $null -eq $App.Arguments -or
                    [string]::IsNullOrWhiteSpace(
                        [string]$App.Arguments
                    )
                ) {

                    Write-DeployLog "No installer arguments specified."

                    $process = Start-Process `
                        -FilePath $Installer `
                        -Wait `
                        -PassThru `
                        -ErrorAction Stop

                }
                else {

                    Write-DeployLog `
                        "Using installer arguments: $($App.Arguments)"

                    $process = Start-Process `
                        -FilePath $Installer `
                        -ArgumentList $App.Arguments `
                        -Wait `
                        -PassThru `
                        -ErrorAction Stop
                }


                # ----------------------------------
                # Capture Exit Code
                # ----------------------------------

                Write-DeployLog `
                    "Installer exit code: $($process.ExitCode)"


                if ($process.ExitCode -eq 0) {

                    Write-DeployLog `
                        "$($App.Name) installed successfully."

                    return $true
                }


                Write-DeployLog `
                    "$($App.Name) exited with code $($process.ExitCode)." `
                    "ERROR"

                return $false
            }


            # ==================================
            # MSIX / APPX
            # ==================================

            "Appx" {

                Write-DeployLog "Mode        : PRODUCTION"
                Write-DeployLog "Installing MSIX package..."


                Add-AppxPackage `
                    -Path $Installer `
                    -ErrorAction Stop


                Write-DeployLog `
                    "$($App.Name) installed successfully."


                return $true
            }


            # ==================================
            # UNKNOWN INSTALLATION METHOD
            # ==================================

            default {

                Write-DeployLog `
                    "Unknown installation method: $($App.InstallMethod)" `
                    "ERROR"

                return $false
            }
        }

    }
    catch {

        Write-DeployLog `
            "$($App.Name) installation failed." `
            "ERROR"


        Write-DeployLog `
            $_.Exception.Message `
            "ERROR"


        return $false
    }

    finally {

        Write-DeployLog `
            "--------------------------------------------"
    }
}