Add-Type -AssemblyName System.Windows.Forms

$gui__appIcon = New-Object System.Drawing.Icon("./assets/app.ico") 

$gui__form = New-Object system.Windows.Forms.Form
$gui__form.clientSize = '458,559'
$gui__form.text = ""
$gui__form.topMost = $false
$gui__form.startPosition = "CenterScreen"
$gui__form.formBorderStyle = 'FixedDialog'

$gui__actionGroup = New-Object system.Windows.Forms.Groupbox
$gui__actionGroup.height = 46
$gui__actionGroup.width = 437
$gui__actionGroup.text = "Action"
$gui__actionGroup.location = New-Object System.Drawing.Point(7,13)

$gui__actionRadio_Backup = New-Object system.Windows.Forms.RadioButton
$gui__actionRadio_Backup.text = "Backup"
$gui__actionRadio_Backup.autoSize = $true
$gui__actionRadio_Backup.width = 104
$gui__actionRadio_Backup.height = 20
$gui__actionRadio_Backup.location = New-Object System.Drawing.Point(109,18)
$gui__actionRadio_Backup.font = 'Microsoft Sans Serif,10'

$gui__actionRadio_Restore = New-Object system.Windows.Forms.RadioButton
$gui__actionRadio_Restore.text = "Restore"
$gui__actionRadio_Restore.autoSize = $true
$gui__actionRadio_Restore.width = 104
$gui__actionRadio_Restore.height = 20
$gui__actionRadio_Restore.location = New-Object System.Drawing.Point(236,20)
$gui__actionRadio_Restore.font = 'Microsoft Sans Serif,10'

$gui__pathGroup = New-Object system.Windows.Forms.Groupbox
$gui__pathGroup.height = 74
$gui__pathGroup.width = 438
$gui__pathGroup.text = "Backup To / Restore From"
$gui__pathGroup.location = New-Object System.Drawing.Point(7,72)

$gui__pathLabel = New-Object system.Windows.Forms.Label
$gui__pathLabel.text = "Choose Folder from Device"
$gui__pathLabel.autoSize = $true
$gui__pathLabel.width = 25
$gui__pathLabel.height = 10
$gui__pathLabel.location = New-Object System.Drawing.Point(10,23)
$gui__pathLabel.font = 'Microsoft Sans Serif,10'

$gui__folderTextBox = New-Object system.Windows.Forms.TextBox
$gui__folderTextBox.multiline = $false
$gui__folderTextBox.width = 346
$gui__folderTextBox.height = 20
$gui__folderTextBox.location = New-Object System.Drawing.Point(10,43)
$gui__folderTextBox.font = 'Microsoft Sans Serif,10'

$gui__appendBackupCheckbox = New-Object system.Windows.Forms.CheckBox
$gui__appendBackupCheckbox.text = "/backup"
$gui__appendBackupCheckbox.autoSize = $false
$gui__appendBackupCheckbox.width = 75
$gui__appendBackupCheckbox.height = 20
$gui__appendBackupCheckbox.location = New-Object System.Drawing.Point(360,45)
$gui__appendBackupCheckbox.font = 'Microsoft Sans Serif,10'
$gui__appendBackupCheckbox.checked = $true

$gui__runGroup = New-Object system.Windows.Forms.Groupbox
$gui__runGroup.height = 391
$gui__runGroup.width = 438
$gui__runGroup.location = New-Object System.Drawing.Point(9,158)

$gui__startButton = New-Object system.Windows.Forms.Button
$gui__startButton.text = "Start Backup/Restore"
$gui__startButton.width = 355
$gui__startButton.height = 30
$gui__startButton.location = New-Object System.Drawing.Point(7,9)
$gui__startButton.font = 'Microsoft Sans Serif,10'

$gui__cancelButton = New-Object system.Windows.Forms.Button
$gui__cancelButton.text = "Cancel"
$gui__cancelButton.width = 60
$gui__cancelButton.height = 30
$gui__cancelButton.location = New-Object System.Drawing.Point(365,9)
$gui__cancelButton.font = 'Microsoft Sans Serif,10'
$gui__cancelButton.enabled = $false

$gui__progressBar = New-Object system.Windows.Forms.ProgressBar
$gui__progressBar.width = 418
$gui__progressBar.height = 15
$gui__progressBar.location = New-Object System.Drawing.Point(8,43)
$gui__progressBar.minimum = 0
$gui__progressBar.maximum = 100
$gui__progressBar.backColor = "#333333"

$gui__progressText = New-Object system.Windows.Forms.TextBox
# $gui__progressText.text = "temp"
$gui__progressText.backColor = "#333333"
$gui__progressText.width = 419
$gui__progressText.readOnly = $true
$gui__progressText.location = New-Object System.Drawing.Point(8,55)
$gui__progressText.font = 'Courier New,10'
$gui__progressText.foreColor = "#cccccc"
$gui__progressText.wordWrap = $false;
$gui__progressText.textAlign = 1;

$gui__progressOutput = New-Object system.Windows.Forms.RichTextBox
$gui__progressOutput.multiline = $true
# $gui__progressOutput.text = "asdfasdf"
$gui__progressOutput.backColor = "#4a4a4a"
$gui__progressOutput.width = 419
$gui__progressOutput.height = 300
$gui__progressOutput.readOnly = $true
$gui__progressOutput.location = New-Object System.Drawing.Point(8,84)
$gui__progressOutput.font = 'Courier New,10'
$gui__progressOutput.foreColor = "#cccccc"
$gui__progressOutput.scrollBars = [System.Windows.Forms.ScrollBars]::Both;
$gui__progressOutput.wordWrap = $false;
$gui__progressOutput.detectUrls = $false;
$gui__progressOutput.shortcutsEnabled = $false;

$gui__toolTip = New-Object system.Windows.Forms.ToolTip
$gui__toolTip.isBalloon = $true

$gui__toolTip.setToolTip($gui__appendBackupCheckbox, 'Will create a "backup" folder')
$gui__form.icon = $gui__appIcon
$gui__actionGroup.controls.addRange(@(
  $gui__actionRadio_Backup,
  $gui__actionRadio_Restore
))
$gui__pathGroup.controls.addRange(@(
  $gui__pathLabel,
  $gui__folderTextBox,
  $gui__appendBackupCheckbox
))
$gui__runGroup.controls.addRange(@(
  $gui__startButton,
  $gui__cancelButton,
  $gui__progressBar,
  $gui__progressText,
  $gui__progressOutput
))
$gui__form.controls.addRange(@(
  $gui__actionGroup,
  $gui__pathGroup,
  $gui__runGroup
))

# Setup event listeners ========================================================

$gui__actionGroup.controls.Add_CheckedChanged({
  if ($this.checked) {
    $gui__pathGroup.text = if ($this.text -eq "Backup") { "Backup To" } else { "Restore From" }
    $gui__startButton.text = "Start $($this.text)"
  }
})

# Set default state after listeners are defined ================================

$gui__actionRadio_Backup.checked = $true
# $gui__actionRadio_Restore.checked = $true
