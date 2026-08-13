# Techsara Desktop Provisioning Utility - Deployment Manager

function Start-Deployment {
    param(
        [Parameter(Mandatory)] [array]$Applications,
        [Parameter(Mandatory)] [string]$ServerPath,
        [Parameter(Mandatory)] [bool]$DevelopmentMode,
        [Parameter(Mandatory)] [System.Windows.Forms.TextBox]$LogControl,
        [Parameter(Mandatory)] [System.Windows.Forms.Label]$StatusControl,
        [Parameter(Mandatory)] [System.Windows.Forms.ProgressBar]$ProgressControl
    )

    $total = $Applications.Count
    $current = 0
    $successCount = 0
    $failureCount = 0

    Write-DeployLog "============================================"
    Write-DeployLog "Deployment Manager Started"
    Write-DeployLog "Applications selected: $total"
    Write-DeployLog "Development Mode: $DevelopmentMode"
    Write-DeployLog "Server: $ServerPath"
    Write-DeployLog "============================================"

    foreach ($app in $Applications) {
        $current++
        $StatusControl.Text = "Processing $($app.Name)..."
        $LogControl.AppendText("[$(Get-Date -Format 'HH:mm:ss')] Starting $($app.Name)...`r`n")
        $LogControl.SelectionStart = $LogControl.Text.Length
        $LogControl.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $result = Install-Application -App $app -ServerPath $ServerPath -DevelopmentMode $DevelopmentMode
            if ($result) {
                $successCount++
                Write-DeployLog "$($app.Name) deployment step completed."
            } else {
                $failureCount++
                Write-DeployLog "$($app.Name) deployment step failed." "ERROR"
            }
        } catch {
            $failureCount++
            Write-DeployLog "Unhandled deployment error for $($app.Name)." "ERROR"
            Write-DeployLog $_.Exception.Message "ERROR"
        }

        $ProgressControl.Value = [math]::Max(0, [math]::Min(100, [math]::Round(($current / $total) * 100)))
        [System.Windows.Forms.Application]::DoEvents()
    }

    Write-DeployLog "============================================"
    Write-DeployLog "Deployment Manager Finished"
    Write-DeployLog "Successful : $successCount"
    Write-DeployLog "Failed     : $failureCount"
    Write-DeployLog "============================================"

    if ($failureCount -eq 0) {
        $StatusControl.Text = "Deployment Completed"
        return $true
    }

    $StatusControl.Text = "Deployment Completed With Errors"
    return $false
}
