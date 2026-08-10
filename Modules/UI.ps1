# ==========================================
# Techsara Desktop Provisioning Utility
# UI Module - v0.4
# ==========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


# ==========================================
# UI LOGGING
# ==========================================

function Write-UILog {

    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$LogControl,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $time = Get-Date -Format "HH:mm:ss"

    $LogControl.AppendText(
        "[$time] $Message`r`n"
    )

    $LogControl.SelectionStart = $LogControl.Text.Length
    $LogControl.ScrollToCaret()

    [System.Windows.Forms.Application]::DoEvents()
}


# ==========================================
# UI STATUS
# ==========================================

function Set-UIStatus {

    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.Label]$StatusControl,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $StatusControl.Text = $Message

    [System.Windows.Forms.Application]::DoEvents()
}


# ==========================================
# UI PROGRESS
# ==========================================

function Update-UIProgress {

    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.ProgressBar]$ProgressControl,

        [Parameter(Mandatory)]
        [int]$Percent
    )

    if ($Percent -lt 0) {
        $Percent = 0
    }

    if ($Percent -gt 100) {
        $Percent = 100
    }

    $ProgressControl.Value = $Percent

    [System.Windows.Forms.Application]::DoEvents()
}


# ==========================================
# SERVER AVAILABILITY CHECK
# ==========================================

function Test-DeploymentServer {

    param(
        [Parameter(Mandatory)]
        [string]$ServerPath
    )

    try {

        return Test-Path `
            -LiteralPath $ServerPath `
            -ErrorAction Stop

    }
    catch {

        return $false
    }
}


# ==========================================
# MAIN WINDOW
# ==========================================

function Show-MainWindow {

    # ======================================
    # FORM
    # ======================================

    $form = New-Object System.Windows.Forms.Form

    $form.Text = "Techsara Desktop Provisioning Utility"

    $form.Size = New-Object System.Drawing.Size(
        900,
        650
    )

    $form.StartPosition = "CenterScreen"

    $form.FormBorderStyle = "FixedDialog"

    $form.MaximizeBox = $false

    $form.MinimizeBox = $true


    # ======================================
    # TITLE
    # ======================================

    $title = New-Object System.Windows.Forms.Label

    $title.Text = "Techsara Solutions"

    $title.Font = New-Object System.Drawing.Font(
        "Segoe UI",
        18,
        [System.Drawing.FontStyle]::Bold
    )

    $title.Location = New-Object System.Drawing.Point(
        20,
        15
    )

    $title.AutoSize = $true

    $form.Controls.Add($title)


    # ======================================
    # SUBTITLE
    # ======================================

    $sub = New-Object System.Windows.Forms.Label

    $sub.Text = "Desktop Provisioning Utility v0.4"

    $sub.Font = New-Object System.Drawing.Font(
        "Segoe UI",
        10
    )

    $sub.Location = New-Object System.Drawing.Point(
        22,
        50
    )

    $sub.AutoSize = $true

    $form.Controls.Add($sub)


    # ======================================
    # SERVER INFORMATION
    # ======================================

    $grpServer = New-Object System.Windows.Forms.GroupBox

    $grpServer.Text = "Server Information"

    $grpServer.Location = New-Object System.Drawing.Point(
        20,
        85
    )

    $grpServer.Size = New-Object System.Drawing.Size(
        840,
        80
    )

    $form.Controls.Add($grpServer)


    # ======================================
    # SERVER PATH
    # ======================================

    $ServerPath = "\\192.168.9.59\FTP - Server\Driver's"


    # ======================================
    # SERVER STATUS LABEL
    # ======================================

    $lblServerStatus = New-Object System.Windows.Forms.Label

    $lblServerStatus.Text = "Status : Checking..."

    $lblServerStatus.ForeColor = [System.Drawing.Color]::DarkOrange

    $lblServerStatus.Font = New-Object System.Drawing.Font(
        "Segoe UI",
        9,
        [System.Drawing.FontStyle]::Bold
    )

    $lblServerStatus.Location = New-Object System.Drawing.Point(
        15,
        22
    )

    $lblServerStatus.AutoSize = $true

    $grpServer.Controls.Add($lblServerStatus)


    # ======================================
    # SERVER PATH LABEL
    # ======================================

    $path = New-Object System.Windows.Forms.Label

    $path.Text = $ServerPath

    $path.Location = New-Object System.Drawing.Point(
        15,
        47
    )

    $path.AutoSize = $true

    $grpServer.Controls.Add($path)


    # ======================================
    # CHECK SERVER
    # ======================================

    $ServerAvailable = Test-DeploymentServer `
        -ServerPath $ServerPath


    if ($ServerAvailable) {

        $lblServerStatus.Text = "Status : Connected"

        $lblServerStatus.ForeColor = `
            [System.Drawing.Color]::Green

    }
    else {

        $lblServerStatus.Text = "Status : Disconnected"

        $lblServerStatus.ForeColor = `
            [System.Drawing.Color]::Red

    }


    # ======================================
    # APPLICATIONS GROUP
    # ======================================

    $grpApps = New-Object System.Windows.Forms.GroupBox

    $grpApps.Text = "Applications"

    $grpApps.Location = New-Object System.Drawing.Point(
        20,
        180
    )

    $grpApps.Size = New-Object System.Drawing.Size(
        320,
        220
    )

    $form.Controls.Add($grpApps)


    # ======================================
    # LOAD APPS.JSON
    # ======================================

    $configPath = Join-Path `
        $PSScriptRoot `
        "..\Config\Apps.json"


    # Stores every checkbox

    $ApplicationControls = @{}

    $cfg = $null


    if (Test-Path $configPath) {

        try {

            $cfg = Get-Content `
                $configPath `
                -Raw |
                ConvertFrom-Json

        }
        catch {

            [System.Windows.Forms.MessageBox]::Show(
                "Unable to read Apps.json.`r`n`r`n$($_.Exception.Message)",
                "Configuration Error",
                "OK",
                "Error"
            )

            return
        }


        # ==================================
        # CREATE APPLICATION CHECKBOXES
        # ==================================

        $y = 25


        foreach ($app in $cfg.Applications) {

            $cb = New-Object System.Windows.Forms.CheckBox

            $cb.Text = $app.Name

            $cb.Checked = $app.Enabled

            $cb.AutoSize = $true

            $cb.Location = New-Object System.Drawing.Point(
                15,
                $y
            )

            $grpApps.Controls.Add($cb)


            # Store checkbox reference

            $ApplicationControls[$app.Name] = $cb


            $y += 28
        }

    }
    else {

        [System.Windows.Forms.MessageBox]::Show(
            "Apps.json was not found.`r`n`r`nExpected location:`r`n$configPath",
            "Configuration Error",
            "OK",
            "Error"
        )

        return
    }


    # ======================================
    # OPTIONAL SOFTWARE
    # ======================================

    $grpOpt = New-Object System.Windows.Forms.GroupBox

    $grpOpt.Text = "Optional Software"

    $grpOpt.Location = New-Object System.Drawing.Point(
        360,
        180
    )

    $grpOpt.Size = New-Object System.Drawing.Size(
        500,
        80
    )

    $form.Controls.Add($grpOpt)


    # ======================================
    # MICROSOFT OFFICE
    # ======================================

    $office = New-Object System.Windows.Forms.CheckBox

    $office.Text = "Install Microsoft Office 2022"

    $office.Location = New-Object System.Drawing.Point(
        20,
        30
    )

    $office.AutoSize = $true

    $grpOpt.Controls.Add($office)


    # ======================================
    # PROGRESS BAR
    # ======================================

    $progress = New-Object System.Windows.Forms.ProgressBar

    $progress.Location = New-Object System.Drawing.Point(
        20,
        425
    )

    $progress.Size = New-Object System.Drawing.Size(
        840,
        24
    )

    $progress.Minimum = 0

    $progress.Maximum = 100

    $progress.Value = 0

    $progress.Style = "Continuous"

    $form.Controls.Add($progress)


    # ======================================
    # STATUS
    # ======================================

    $status = New-Object System.Windows.Forms.Label

    $status.Text = "Ready..."

    $status.Font = New-Object System.Drawing.Font(
        "Segoe UI",
        9
    )

    $status.Location = New-Object System.Drawing.Point(
        20,
        455
    )

    $status.AutoSize = $true

    $form.Controls.Add($status)


    # ======================================
    # DEPLOYMENT LOG
    # ======================================

    $grpLog = New-Object System.Windows.Forms.GroupBox

    $grpLog.Text = "Deployment Log"

    $grpLog.Location = New-Object System.Drawing.Point(
        360,
        275
    )

    $grpLog.Size = New-Object System.Drawing.Size(
        500,
        120
    )

    $form.Controls.Add($grpLog)


    $log = New-Object System.Windows.Forms.TextBox

    $log.Multiline = $true

    $log.ReadOnly = $true

    $log.ScrollBars = "Vertical"

    $log.WordWrap = $false

    $log.Dock = "Fill"

    $log.Text = "Ready...`r`n"

    $grpLog.Controls.Add($log)


    # ======================================
    # START DEPLOYMENT BUTTON
    # ======================================

    $start = New-Object System.Windows.Forms.Button

    $start.Text = "Start Deployment"

    $start.Size = New-Object System.Drawing.Size(
        180,
        45
    )

    $start.Location = New-Object System.Drawing.Point(
        240,
        530
    )


    $start.Add_Click({

        # ==================================
        # CHECK SERVER BEFORE DEPLOYMENT
        # ==================================

        $ServerAvailable = Test-DeploymentServer `
            -ServerPath $ServerPath


        if (-not $ServerAvailable) {

            Set-UIStatus `
                -StatusControl $status `
                -Message "Deployment server unavailable."


            Write-UILog `
                -LogControl $log `
                -Message "ERROR: Deployment server unavailable."


            [System.Windows.Forms.MessageBox]::Show(
                "The deployment server is unavailable.`r`n`r`n$ServerPath",
                "Deployment Server Unavailable",
                "OK",
                "Error"
            )

            return
        }


        # ==================================
        # DISABLE BUTTON
        # ==================================

        $start.Enabled = $false


        # ==================================
        # RESET UI
        # ==================================

        Set-UIStatus `
            -StatusControl $status `
            -Message "Preparing Deployment..."


        Update-UIProgress `
            -ProgressControl $progress `
            -Percent 0


        $log.Clear()


        Write-UILog `
            -LogControl $log `
            -Message "=========== Deployment Started ==========="


        Write-UILog `
            -LogControl $log `
            -Message "Deployment server verified."


        # ==================================
        # GET SELECTED APPLICATIONS
        # ==================================

        $selectedApps = @()


        foreach ($app in $cfg.Applications) {

            if ($ApplicationControls.ContainsKey($app.Name)) {

                if ($ApplicationControls[$app.Name].Checked) {

                    $selectedApps += $app
                }
            }
        }


        # ==================================
        # NOTHING SELECTED
        # ==================================

        if ($selectedApps.Count -eq 0) {

            Write-UILog `
                -LogControl $log `
                -Message "No applications selected."


            Set-UIStatus `
                -StatusControl $status `
                -Message "Nothing to deploy."


            $start.Enabled = $true

            return
        }


        # ==================================
        # DEVELOPMENT WORKFLOW
        # ==================================

        $total = $selectedApps.Count

        $current = 0


        foreach ($app in $selectedApps) {

            $current++


            Set-UIStatus `
                -StatusControl $status `
                -Message "Preparing $($app.Name)..."


            Write-UILog `
                -LogControl $log `
                -Message "Preparing $($app.Name)..."


            $percent = [math]::Round(
                ($current / $total) * 100
            )


            Update-UIProgress `
                -ProgressControl $progress `
                -Percent $percent


            # Temporary development delay.
            # This will be replaced by the
            # DeploymentManager in the next phase.

            Start-Sleep -Milliseconds 500
        }


        # ==================================
        # OFFICE SELECTION
        # ==================================

        if ($office.Checked) {

            Write-UILog `
                -LogControl $log `
                -Message "Microsoft Office 2022 selected."

        }
        else {

            Write-UILog `
                -LogControl $log `
                -Message "Microsoft Office 2022 not selected."

        }


        # ==================================
        # DEPLOYMENT FINISHED
        # ==================================

        Set-UIStatus `
            -StatusControl $status `
            -Message "Deployment Ready"


        Write-UILog `
            -LogControl $log `
            -Message "=========================================="


        Write-UILog `
            -LogControl $log `
            -Message "Deployment workflow completed."


        $start.Enabled = $true

    })


    $form.Controls.Add($start)


    # ======================================
    # EXIT BUTTON
    # ======================================

    $exit = New-Object System.Windows.Forms.Button

    $exit.Text = "Exit"

    $exit.Size = New-Object System.Drawing.Size(
        120,
        45
    )

    $exit.Location = New-Object System.Drawing.Point(
        460,
        530
    )


    $exit.Add_Click({

        $form.Close()

    })


    $form.Controls.Add($exit)


    # ======================================
    # SHOW FORM
    # ======================================

    [void]$form.ShowDialog()
}