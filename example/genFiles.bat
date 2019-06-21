if not exist ".\output" mkdir ".\output"
if not exist ".\source" mkdir ".\source"
  if not exist ".\source\Multi" mkdir ".\source\Multi"
    if not exist ".\source\Multi\folder1" mkdir ".\source\Multi\folder1"
    if not exist ".\source\Multi\folder2" mkdir ".\source\Multi\folder2"
    if not exist ".\source\Multi\folder3" mkdir ".\source\Multi\folder3"
  if not exist ".\source\Music" mkdir ".\source\Music"
    if not exist ".\source\Music\Album 01" mkdir ".\source\Music\Album 01"
    if not exist ".\source\Music\Album 02" mkdir ".\source\Music\Album 02"
  if not exist ".\source\Projects" mkdir ".\source\Projects"
    if not exist ".\source\Projects\project" mkdir ".\source\Projects\project"
      if not exist ".\source\Projects\project\node_modules" mkdir ".\source\Projects\project\node_modules"
      if not exist ".\source\Projects\project\logs" mkdir ".\source\Projects\project\logs"
      if not exist ".\source\Projects\project\dist" mkdir ".\source\Projects\project\dist"

REM KB = 1024 bytes
REM MB = 1,048,576 bytes
set /a SMALL_FILE_SIZE=1024*2
set /a MEDIUM_FILE_SIZE=1048576*5
set /a LARGE_FILE_SIZE=1048576*100

REM multi
fsutil file createnew ".\source\Multi\folder1\data.json" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Multi\folder1\vid.mkv" %LARGE_FILE_SIZE%
fsutil file createnew ".\source\Multi\folder2\data.json" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Multi\folder3\data.json" %SMALL_FILE_SIZE%
REM music
fsutil file createnew ".\source\Music\playlist.m3u" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Music\Album 01\01.mp3" %MEDIUM_FILE_SIZE%
fsutil file createnew ".\source\Music\Album 01\02.mp3" %MEDIUM_FILE_SIZE%
fsutil file createnew ".\source\Music\Album 01\folder.jpg" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Music\Album 02\01.mp3" %MEDIUM_FILE_SIZE%
REM projects
fsutil file createnew ".\source\Projects\project\node_modules\module.js" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Projects\project\logs\error.log" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Projects\project\dist\app.js" %SMALL_FILE_SIZE%
fsutil file createnew ".\source\Projects\project\package.json" %SMALL_FILE_SIZE%

REM pause
