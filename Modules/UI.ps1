# Techsara Desktop Provisioning Utility - UI Module v0.5
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Write-UILog {
    param([Parameter(Mandatory)][System.Windows.Forms.TextBox]$LogControl,
          [Parameter(Mandatory)][string]$Message)
    $time = Get-Date -Format "HH:mm:ss"
    $LogControl.AppendText("[$time] $Message`r`n")
    $LogControl.SelectionStart = $LogControl.Text.Length
    $LogControl.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-UIStatus {
    param([Parameter(Mandatory)][System.Windows.Forms.Label]$StatusControl,
          [Parameter(Mandatory)][string]$Message)
    $StatusControl.Text = $Message
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-UIProgress {
    param([Parameter(Mandatory)][System.Windows.Forms.ProgressBar]$ProgressControl,
          [Parameter(Mandatory)][int]$Percent)
    $Percent = [math]::Max(0, [math]::Min(100, $Percent))
    $ProgressControl.Value = $Percent
    [System.Windows.Forms.Application]::DoEvents()
}

function Test-DeploymentServer {
    param([Parameter(Mandatory)][string]$ServerPath)
    try { return Test-Path -LiteralPath $ServerPath -ErrorAction Stop }
    catch { return $false }
}

function Show-MainWindow {
    param(
        [Parameter(Mandatory)]
        [bool]$DevelopmentMode
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Techsara Desktop Provisioning Utility"
    $form.Size = New-Object System.Drawing.Size(900,650)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Techsara Solutions"
    $title.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
    $title.Location = New-Object System.Drawing.Point(20,15)
    $title.AutoSize = $true
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = "Desktop Provisioning Utility v0.5"
    $sub.Location = New-Object System.Drawing.Point(22,50)
    $sub.AutoSize = $true
    $form.Controls.Add($sub)

    $grpServer = New-Object System.Windows.Forms.GroupBox
    $grpServer.Text = "Server Information"
    $grpServer.Location = New-Object System.Drawing.Point(20,85)
    $grpServer.Size = New-Object System.Drawing.Size(840,80)
    $form.Controls.Add($grpServer)

    $ServerPath = "\\192.168.9.59\FTP - Server\Driver's"

    $lblServerStatus = New-Object System.Windows.Forms.Label
    $lblServerStatus.Text = "Status : Checking..."
    $lblServerStatus.ForeColor = [System.Drawing.Color]::DarkOrange
    $lblServerStatus.Location = New-Object System.Drawing.Point(15,22)
    $lblServerStatus.AutoSize = $true
    $grpServer.Controls.Add($lblServerStatus)

    $path = New-Object System.Windows.Forms.Label
    $path.Text = $ServerPath
    $path.Location = New-Object System.Drawing.Point(15,47)
    $path.AutoSize = $true
    $grpServer.Controls.Add($path)

    if (Test-DeploymentServer $ServerPath) {
        $lblServerStatus.Text = "Status : Connected"
        $lblServerStatus.ForeColor = [System.Drawing.Color]::Green
    } else {
        $lblServerStatus.Text = "Status : Disconnected"
        $lblServerStatus.ForeColor = [System.Drawing.Color]::Red
    }

    $grpApps = New-Object System.Windows.Forms.GroupBox
    $grpApps.Text = "Applications"
    $grpApps.Location = New-Object System.Drawing.Point(20,180)
    $grpApps.Size = New-Object System.Drawing.Size(320,220)
    $form.Controls.Add($grpApps)

    $configPath = Join-Path $PSScriptRoot "..\Config\Apps.json"
    if (-not (Test-Path $configPath)) {
        [System.Windows.Forms.MessageBox]::Show("Apps.json was not found.`r`n$configPath","Configuration Error","OK","Error")
        return
    }

    try { $cfg = Get-Content $configPath -Raw | ConvertFrom-Json }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Unable to read Apps.json.`r`n$($_.Exception.Message)","Configuration Error","OK","Error")
        return
    }

    $ApplicationControls = @{}
    $y = 25
    foreach ($app in $cfg.Applications) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $app.Name
        $cb.Checked = $app.Enabled
        $cb.AutoSize = $true
        $cb.Location = New-Object System.Drawing.Point(15,$y)
        $grpApps.Controls.Add($cb)
        $ApplicationControls[$app.Name] = $cb
        $y += 28
    }

    $grpOpt = New-Object System.Windows.Forms.GroupBox
    $grpOpt.Text = "Optional Software"
    $grpOpt.Location = New-Object System.Drawing.Point(360,180)
    $grpOpt.Size = New-Object System.Drawing.Size(500,80)
    $form.Controls.Add($grpOpt)

    $office = New-Object System.Windows.Forms.CheckBox
    $office.Text = "Install Microsoft Office 2022"
    $office.Location = New-Object System.Drawing.Point(20,30)
    $office.AutoSize = $true
    $grpOpt.Controls.Add($office)

    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Location = New-Object System.Drawing.Point(20,425)
    $progress.Size = New-Object System.Drawing.Size(840,24)
    $progress.Style = "Continuous"
    $form.Controls.Add($progress)

    $status = New-Object System.Windows.Forms.Label
    $status.Text = "Ready..."
    $status.Location = New-Object System.Drawing.Point(20,455)
    $status.AutoSize = $true
    $form.Controls.Add($status)

    $grpLog = New-Object System.Windows.Forms.GroupBox
    $grpLog.Text = "Deployment Log"
    $grpLog.Location = New-Object System.Drawing.Point(360,275)
    $grpLog.Size = New-Object System.Drawing.Size(500,120)
    $form.Controls.Add($grpLog)

    $log = New-Object System.Windows.Forms.TextBox
    $log.Multiline = $true
    $log.ReadOnly = $true
    $log.ScrollBars = "Vertical"
    $log.WordWrap = $false
    $log.Dock = "Fill"
    $log.Text = "Ready...`r`n"
    $grpLog.Controls.Add($log)

    $start = New-Object System.Windows.Forms.Button
    $start.Text = "Start Deployment"
    $start.Size = New-Object System.Drawing.Size(180,45)
    $start.Location = New-Object System.Drawing.Point(240,530)

    $start.Add_Click({
        if (-not (Test-DeploymentServer $ServerPath)) {
            Set-UIStatus $status "Deployment server unavailable."
            Write-UILog $log "ERROR: Deployment server unavailable."
            [System.Windows.Forms.MessageBox]::Show(
                "The deployment server is unavailable.`r`n$ServerPath",
                "Deployment Server Unavailable","OK","Error")
            return
        }

        $start.Enabled = $false
        Set-UIStatus $status "Preparing Deployment..."
        Update-UIProgress $progress 0
        $log.Clear()
        Write-UILog $log "=========== Deployment Started ==========="
        Write-UILog $log "Deployment server verified."

        $selectedApps = @()
        foreach ($app in $cfg.Applications) {
            if ($ApplicationControls.ContainsKey($app.Name) -and $ApplicationControls[$app.Name].Checked) {
                $selectedApps += $app
            }
        }

        if ($selectedApps.Count -eq 0) {
            Write-UILog $log "No applications selected."
            Set-UIStatus $status "Nothing to deploy."
            $start.Enabled = $true
            return
        }

        $deploymentResult = Start-Deployment `
            -Applications $selectedApps `
            -ServerPath $ServerPath `
            -DevelopmentMode $DevelopmentMode `
            -LogControl $log `
            -StatusControl $status `
            -ProgressControl $progress

        if ($office.Checked) {
            Write-UILog $log "Microsoft Office 2022 selected."
            Write-UILog $log "Office deployment is not yet connected."
        } else {
            Write-UILog $log "Microsoft Office 2022 not selected."
        }

        if ($deploymentResult) {
            Set-UIStatus $status "Deployment Completed"
            Write-UILog $log "Deployment completed successfully."
        } else {
            Set-UIStatus $status "Deployment Completed With Errors"
            Write-UILog $log "Deployment completed with errors."
        }

        $start.Enabled = $true
    })
    $form.Controls.Add($start)

    $exit = New-Object System.Windows.Forms.Button
    $exit.Text = "Exit"
    $exit.Size = New-Object System.Drawing.Size(120,45)
    $exit.Location = New-Object System.Drawing.Point(460,530)
    $exit.Add_Click({ $form.Close() })
    $form.Controls.Add($exit)

    [void]$form.ShowDialog()
}
