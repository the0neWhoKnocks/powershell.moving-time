Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import the utils
. ".\assets\utils.ps1"

# Import config
# $conf = Import-PowerShellDataFile ".\conf.psd1"
$conf = Import-PowerShellDataFile ".\example\conf.psd1"

$nl = [Environment]::NewLine
$BACKUP_SUFFIX = "\backup"
$LOG_PATH = ".\sync.log"
$global:currSyncNdx = 0

hideConsole # comment out to see the PS terminal for debugging

# Import the GUI
. ".\assets\gui.ps1"

$global:bagPath = if($conf.bagPath){ $conf.bagPath } else{ $pwd.path }
function setBagPath($path) {
  if(!$path){
    $path = $global:bagPath
  }
  
  $finalPath = "$path"
  if(
    !$finalPath.endsWith($BACKUP_SUFFIX) `
    -And $gui__appendBackupCheckbox.checked
  ){ $finalPath += $BACKUP_SUFFIX }
  else {
    $path = $finalPath.replace($BACKUP_SUFFIX, '')
    $finalPath = $finalPath.replace($BACKUP_SUFFIX, '')
  }
  
  $pathPrefix = if($gui__actionRadio_Backup.checked){ 'Backup to' }else{ 'Restore from' }

  $gui__folderTextBox.text = $path
  logToOutput("$($pathPrefix): $finalPath")
  $global:bagPath = $finalPath
}

function onProgress {
  if(Test-Path $LOG_PATH){
    $percentage = 0;
    
    while($null -ne ($line = $global:logFileReader.readLine())) {
      # Handle errors
      $errorFound = Select-String -CaseSensitive -InputObject "$line" ".* ERROR .*"
      if($errorFound){
        $errorMsg = "$line"
        while($null -ne ($errLine = $global:logFileReader.readLine())) {
          $errorMsg += "$nl$errLine"
        }
        
        logToColoredOutput `
          @{ color = "WHITE_ON_RED"; text = " ERROR " } `
          @{ color = "ORANGE"; text = " $errorMsg" }
        
        stopJob
        
        break
      }
      else {
        # Find the current file being processed
        $currFilePath = [Regex]::Matches("$line", "\t\s\s\t\t\t(.*\.[a-z0-9]{2,4})")
        if($currFilePath.success) { 
          $global:progressMsg = "$($currFilePath.value.trim())"
        }
        
        # Find the percentage-complete for the file being synced
        $perc = [Regex]::Matches("$line", '[0-9.]+%$')
        if($perc.success){ $percentage = [int]( $perc.value.replace('%', '') ) }
      }
    }
    
    if($global:progressMsg){ logToProgress("$global:progressMsg") }
    $gui__progressBar.value = $percentage
  }
}

function syncFiles($pathNdx) {
  # find the first item not synced
  $global:currSync = $conf.itemsList[$global:currSyncNdx]
  $global:pathNdx = $pathNdx
  $currPath = $global:currSync.paths[$global:pathNdx]
  
  # Transform relative paths to absolute paths, based on the folder where the
  # script is being executed from.
  if($currPath.startsWith('.\')){
    $currPath = $currPath.replace('.\', "$pwd\")
  }
  # To have a true backup, use the same path structure from source, but
  # replace the drive letter prefix with a folder name syntax.
  $transformedBagPath = "$( $global:bagPath )\$( $currPath.replace(':', '') )"
  
  $from = $currPath
  $to = $transformedBagPath
  if($gui__actionRadio_Restore.checked){
    $from = $transformedBagPath
    $to = $currPath
  }
  
  if($global:pathNdx -gt 0){
    logToOutput("  ------$nl  From: $from$nl    To: $to")
  }
  else {
    logToColoredOutput `
      "$nl" `
      @{ color = "BLACK_ON_GREEN"; text = " SYNCING " } `
      " $($global:currSync.label)$nl  From: $from$nl    To: $to"
  }
  
  $syncArgs = @{
    Source = $from
    Destination = $to
    Gap = 10
    logPath = "$LOG_PATH"
    scriptPath = $pwd
    recursive = if($global:currSync.recursive -eq $false){ $false }else{ $true }
  }
  if($global:currSync.filters){ $syncArgs["filters"] = $global:currSync.filters }
  if($global:currSync.excludedFolders){ $syncArgs["excludedFolders"] = $global:currSync.excludedFolders }
  if($global:currSync.excludedFiles){ $syncArgs["excludedFiles"] = $global:currSync.excludedFiles }
  
  $global:timer = New-Object System.Windows.Forms.Timer
  $timer.interval = 100
  
  try {
    $global:logFileStream = New-Object IO.FileStream("$LOG_PATH", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [IO.FileShare]::ReadWrite)
    $global:logFileReader = New-Object System.IO.StreamReader($logFileStream)
    
    $global:job = Start-Job `
      -Name "fileSync" `
      -ArgumentList ([hashtable]$syncArgs) `
      -FilePath "./assets/syncFiles.ps1"
    $timer.add_tick({
      $timer = $global:timer
      
      if($global:job){
        # Update gui with job data
        if(
          $global:job.state -eq "Running" `
          -Or $global:job.state -eq "Blocked"
        ) { onProgress }
        # Current sync is done, move on to the next one, or everything is synced
        else {
          stopJob
          
          # All child item paths have been synced
          # AND all items have been synced
          if(
            $global:currSync.paths.count - 1 -eq $global:pathNdx `
            -And $conf.itemsList.count - 1 -eq $global:currSyncNdx
          ){
            $timer.stop()
            logToProgress("")
            logToColoredOutput `
              "$nl" `
              @{ color = "BLACK_ON_GREEN"; text = " $global:verb " } `
              " Completed"
            $gui__progressBar.style = [System.Windows.Forms.ProgressBarStyle]::Continuous
            $gui__progressBar.ForeColor = "#00FFCC"
            $gui__progressBar.value = 100 # if the process finishes quickly this won't be set
            $global:currSyncNdx = 0
            $global:logFileReader.Dispose()
            $global:logFileStream.Dispose()
            Remove-Item "$LOG_PATH"
            allowSleep
          }
          # items still need to sync, keep going
          else {
            if($global:currSync.paths.count - 1 -eq $global:pathNdx){
              logToOutput "  ------$nl  $($global:currSyncNdx + 1) of $($conf.itemsList.count) items synced"
              $global:currSyncNdx += 1
              $global:pathNdx = 0
            }
            else {
              $global:pathNdx += 1
            }
            
            $global:logFileReader.Dispose()
            $global:logFileStream.Dispose()
            Remove-Item "$LOG_PATH"
            syncFiles($global:pathNdx)
          }
        }
      }
    })
    $timer.start()
    $gui__cancelButton.enabled = $true
  }
  catch {
    log "An error occurred: $($_)"
  }
}

function stopJob {
  if($global:job){
    $global:timer.stop()
    $gui__cancelButton.enabled = $false
    
    if($global:job.state -eq "Running") {                
      Stop-Job -Job $global:job
      if(Get-Process robocopy -ErrorAction SilentlyContinue){
        Stop-Process -Name robocopy;
      }
      $global:currSyncNdx = 0
      
      logToOutput("  sync job cancelled")
      logToProgress("")
      $gui__progressBar.value = 0
      $global:logFileReader.Dispose()
      $global:logFileStream.Dispose()
      Remove-Item "$LOG_PATH"
      allowSleep
    }
    # else { logToOutput "  sync job done" }
    
    Remove-Job -Job $global:job
    $global:job = $null
  }
}

# Customize & Assign functionality to the GUI ----------------------------------
$gui__form.text = "Moving Time"
$gui__form.Add_Shown({
  setBagPath
})
$gui__appendBackupCheckbox.Add_CheckedChanged({
  setBagPath
})
$gui__folderTextBox.Add_Click({
  $folder = getFolder($global:bagPath)
  
  if($folder){
    setBagPath($folder)
  }
})
$gui__cancelButton.Add_Click({ stopJob })
$gui__startButton.Add_Click({
  $pathToCheck = $global:bagPath
  if($gui__appendBackupCheckbox.checked){
    $pathToCheck = $pathToCheck.replace($BACKUP_SUFFIX, '')
  }
  
  $bagPathExists = checkPath($pathToCheck)
  if ($bagPathExists -eq $false) {
    logToColoredOutput `
      @{ color = "WHITE_ON_RED"; text = " ERROR " } `
      @{ color = "ORANGE"; text = " The output path doesn't exist '$pathToCheck'" }
  } else {
    $global:verb = if($gui__actionRadio_Backup.checked){ 'BACKUP' }else{ 'RESTORE' }
    
    $gui__progressOutput.text = ""
    
    logToColoredOutput `
      @{ color = "BLACK_ON_GREEN"; text = " $global:verb " } `
      " Starting"
    
    $gui__progressBar.style = [System.Windows.Forms.ProgressBarStyle]::Blocks
    $gui__progressBar.ForeColor = "#00CCFF"
    $gui__progressBar.value = 0
    preventSleep
    syncFiles(0)
  }
});

# Display the GUI
$gui__form.add_FormClosing({ stopJob })
[void]$gui__form.showDialog()
