$opts = $args[0]
$Source = $opts.Source
$Destination = $opts.Destination
$Gap = if($opts.Gap){ $opts.Gap }else{ 500 }
$scriptPath = $opts.scriptPath
$recursive = if($opts.recursive -eq $false){ $false }else{ $true }
$filters = if($opts.filters){ $opts.filters }else{ "" }
$excludedFolders = if($opts.excludedFolders){ $opts.excludedFolders }else{ "" }
$logPath = if($opts.logPath){ $opts.logPath }else{ "./sync.log" }

# cd to working directory for background-process
Push-Location $scriptPath

$RegexBytes = '(?<=\s+)\d+(?=\s+)';
# Robocopy params - https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#copy-options
# MIR   - Mirror mode
# NDL   - Directory names are not to be logged
# NC    - Don't log file classes (existing, new file, etc.)
# NJH   - Do not display robocopy job header (JH)
# NJS   - Do not display robocopy job summary (JS)
# R     - Number of times to retry
# W     - Time to wait between retries (in seconds)
# FFT   - Assumes FAT file times (two-second precision).
# Z     - Copies files in restartable mode.
# NS    - No file size.
$CommonRobocopyParams = '/MIR /NDL /NC /NJH /NJS /R:1 /W:3 /FFT /Z /NS';
# E     - Copies subdirectories. Note that this option includes empty directories.
if($recursive){ $CommonRobocopyParams += ' /E' }
# LEV:n - Only copy the top n LEVels of the source tree.
else {
  $CommonRobocopyParams += ' /LEV:0'
  $CommonRobocopyParams = $CommonRobocopyParams.replace('/MIR ', '')
}
# XD    - Excludes specific directories
if($excludedFolders){ $CommonRobocopyParams += " /XD $excludedFolders" }
# XF    - Excludes files that match the specified names or paths. Note that FileName can include wildcard characters (* and ?).
if($excludedFiles){ $CommonRobocopyParams += " /XF $excludedFiles" }

# /ipg:n - Specifies the inter-packet gap to free bandwidth on slow lines.
$Robocopy = Start-Process `
  -Wait `
  -WindowStyle Minimized `
  -FilePath robocopy.exe `
  -ArgumentList "`"$Source`" `"$Destination`" $filters /UNILOG+:`"$logPath`" /IPG:$Gap $CommonRobocopyParams"
