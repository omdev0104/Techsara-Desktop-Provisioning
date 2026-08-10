# Techsara Desktop Provisioning Utility
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-MainWindow {

$form=New-Object System.Windows.Forms.Form
$form.Text='Techsara Desktop Provisioning Utility'
$form.Size=New-Object System.Drawing.Size(900,650)
$form.StartPosition='CenterScreen'
$form.FormBorderStyle='FixedDialog'
$form.MaximizeBox=$false

$title=New-Object System.Windows.Forms.Label
$title.Text='Techsara Solutions'
$title.Font=New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold)
$title.Location=New-Object System.Drawing.Point(20,15)
$title.AutoSize=$true
$form.Controls.Add($title)

$sub=New-Object System.Windows.Forms.Label
$sub.Text='Desktop Provisioning Utility v0.4'
$sub.Location=New-Object System.Drawing.Point(22,50)
$sub.AutoSize=$true
$form.Controls.Add($sub)

$grpServer=New-Object System.Windows.Forms.GroupBox
$grpServer.Text='Server Information'
$grpServer.Location=New-Object System.Drawing.Point(20,85)
$grpServer.Size=New-Object System.Drawing.Size(840,80)
$form.Controls.Add($grpServer)

$lbl=New-Object System.Windows.Forms.Label
$lbl.Text='Status : Connected'
$lbl.ForeColor='Green'
$lbl.Location=New-Object System.Drawing.Point(15,25)
$lbl.AutoSize=$true
$grpServer.Controls.Add($lbl)

$path=New-Object System.Windows.Forms.Label
$path.Text="\\192.168.9.59\FTP - Server\Driver's"
$path.Location=New-Object System.Drawing.Point(15,48)
$path.AutoSize=$true
$grpServer.Controls.Add($path)

$grpApps=New-Object System.Windows.Forms.GroupBox
$grpApps.Text='Applications'
$grpApps.Location=New-Object System.Drawing.Point(20,180)
$grpApps.Size=New-Object System.Drawing.Size(320,220)
$form.Controls.Add($grpApps)

$configPath=Join-Path $PSScriptRoot '..\Config\Apps.json'
if(Test-Path $configPath){
 $cfg=Get-Content $configPath -Raw|ConvertFrom-Json
 $y=25
 foreach($app in $cfg.Applications){
  $cb=New-Object System.Windows.Forms.CheckBox
  $cb.Text=$app.Name
  $cb.Checked=$app.Enabled
  $cb.Location=New-Object System.Drawing.Point(15,$y)
  $cb.AutoSize=$true
  $grpApps.Controls.Add($cb)
  $y+=28
 }
}

$grpOpt=New-Object System.Windows.Forms.GroupBox
$grpOpt.Text='Optional Software'
$grpOpt.Location=New-Object System.Drawing.Point(360,180)
$grpOpt.Size=New-Object System.Drawing.Size(500,80)
$form.Controls.Add($grpOpt)

$office=New-Object System.Windows.Forms.CheckBox
$office.Text='Install Microsoft Office 2022'
$office.Location=New-Object System.Drawing.Point(20,30)
$office.AutoSize=$true
$grpOpt.Controls.Add($office)

$progress=New-Object System.Windows.Forms.ProgressBar
$progress.Location=New-Object System.Drawing.Point(20,425)
$progress.Size=New-Object System.Drawing.Size(840,24)
$progress.Style='Continuous'
$form.Controls.Add($progress)

$status=New-Object System.Windows.Forms.Label
$status.Text='Ready...'
$status.Location=New-Object System.Drawing.Point(20,455)
$status.AutoSize=$true
$form.Controls.Add($status)

$grpLog=New-Object System.Windows.Forms.GroupBox
$grpLog.Text='Deployment Log'
$grpLog.Location=New-Object System.Drawing.Point(360,275)
$grpLog.Size=New-Object System.Drawing.Size(500,120)
$form.Controls.Add($grpLog)

$log=New-Object System.Windows.Forms.TextBox
$log.Multiline=$true
$log.ReadOnly=$true
$log.ScrollBars='Vertical'
$log.Dock='Fill'
$log.Text="Ready...`r`n"
$grpLog.Controls.Add($log)

$start=New-Object System.Windows.Forms.Button
$start.Text='Start Deployment'
$start.Size=New-Object System.Drawing.Size(180,45)
$start.Location=New-Object System.Drawing.Point(240,530)
$start.Add_Click({
 $status.Text='Deployment Started...'
 $progress.Value=10
 $log.AppendText('Starting deployment...`r`n')
 $log.AppendText('Backend integration in Part 2.`r`n')
})
$form.Controls.Add($start)

$exit=New-Object System.Windows.Forms.Button
$exit.Text='Exit'
$exit.Size=New-Object System.Drawing.Size(120,45)
$exit.Location=New-Object System.Drawing.Point(460,530)
$exit.Add_Click({$form.Close()})
$form.Controls.Add($exit)

[void]$form.ShowDialog()

}