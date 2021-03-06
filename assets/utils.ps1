# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
# .Net methods for preventing the computer from going to sleep
# source - https://blog.backslasher.net/windows-awake-ps.html
Add-Type -Name System -Namespace Win32 -MemberDefinition '
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
public static extern void SetThreadExecutionState(uint esFlags);
'

function log($msg) { Write-Host $msg }

function logToProgress ($msg) {
  $gui__progressText.text = $msg
  $gui__progressText.select($gui__progressText.text.length, 0)
}

function logToOutput ($msg, $addNewLine) {
  $nl = if($addNewLine -ne $false){ [Environment]::NewLine }else{ "" }
  $formattedMsg = "$msg$nl"
  
  $gui__progressOutput.appendText($formattedMsg)
  $gui__progressOutput.scrollToCaret()
}

function logToColoredOutput {
  $colors = @{
    BLACK_ON_GREEN = @("#000000", "#00FF00")
    ORANGE = @("#ff5722")
    WHITE_ON_RED = @("#FFFFFF", "#FF0000")
  }
  
  for($i = 0; $i -lt $args.count; $i++){
    $arg = $args[$i]
    $addNewLine = if($i -eq $args.count - 1){ $true }else{ $false }
    
    # colored string
    if($arg -is [hashtable]){
      $start = $gui__progressOutput.textLength;
      logToOutput $arg.text $addNewLine
      $end = $gui__progressOutput.textLength;
      $color = $colors[$arg.color]
      # colorize text
      $gui__progressOutput.select($start, $end - $start)
      if($color[0]){ $gui__progressOutput.selectionColor = $color[0]; }
      if($color[1]){ $gui__progressOutput.selectionBackColor = $color[1]; }
      # reset color for any remaining text
      $gui__progressOutput.select($end, 0)
      $gui__progressOutput.selectionColor = $gui__progressOutput.foreColor;
      $gui__progressOutput.selectionBackColor = $gui__progressOutput.backColor;
    }
    # normal string
    else {
      logToOutput $arg $addNewLine
    }
  }
}

function checkPath($path) {
  if (!(Test-Path $path)) { return $false }
}

function centerForm($form) {
  $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $form.SetDesktopLocation(
    ($bounds.width - $form.width) / 2,
    ($bounds.height - $form.height) / 2
  )
}

function hideConsole {
  $consolePtr = [Console.Window]::GetConsoleWindow()
  # 0 hide
  [Console.Window]::ShowWindow($consolePtr, 0)
}

function getFolder($initialDirectory){
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
  $folderBrowser.Description = "Select a folder"
  $folderBrowser.rootfolder = "MyComputer"
  
  if($initialDirectory){
    $folderBrowser.SelectedPath = $initialDirectory
  }

  if($folderBrowser.ShowDialog() -eq "OK"){
    $folder += $folderBrowser.SelectedPath
  }
  
  return $folder
}

# Requests that the other EXECUTION_STATE flags set remain in effect until SetThreadExecutionState is called again with the ES_CONTINUOUS flag set and one of the other EXECUTION_STATE flags cleared.
$ES_CONTINUOUS = [uint32]"0x80000000"
function preventSleep(){
  # Requests system availability (sleep idle timeout is prevented).
  $ES_SYSTEM_REQUIRED = [uint32]"0x00000001"
  [Win32.System]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED)
}
function allowSleep(){
  [Win32.System]::SetThreadExecutionState($ES_CONTINUOUS)
}
