# Moving Time

A Powershell script that allows a user to backup and restore a list of files or
file paths via a GUI.

![demo](https://user-images.githubusercontent.com/344140/59949795-0e89e980-9429-11e9-9ee7-671a3558ca41.gif)

---

## Demo the script

- Clone or download this repo
- Go into the `example` folder and double-click the `genFiles.bat` file. It'll
then set up some folders and files of varying sizes.
- Then go back up to the root of this repo and right-click `moving-time.ps1`
and select **Run with Powershell**.
- Once the GUI opens, click the **Start Backup** button.
  - Once the script has completed you'll see the `example/output` folder now has
  a `backup` folder in it, with the folders and files specified in
  `example/conf.psd1`.
- After the backup has completed, rename `example/source` to
`example/source.bak`.
- Click the **Restore** radio at the top of the GUI and then click the
**Start Restore** button.
  - Once the script has completed you'll see the `example/source` folder has
  been created, containing the files and folders from `example/output`.

---

## Create your own config

- Copy the file `example/conf.psd1` to the root of the repo
- At the top of `moving-time.ps1`
  - Find the `# Import config` line, and edit the below lines to look like:
  ```powershell
  $conf = Import-PowerShellDataFile ".\conf.psd1"
  # $conf = Import-PowerShellDataFile ".\example\conf.psd1"
  ```

Here are the available top-level options for a config:

| Prop | Type | Value |
| ---- | ---- | ----- |
| `bagPath` | `String` | Absolute or relative path to where files will be backed up to or restored from. |
| `itemsList` | `Array` of `HashTable` | |

The available properties for `itemsList` are listed below. Optional properties
are surrounded in `[<NAME>]`.

| Prop | Type | Value |
| ---- | ---- | ----- |
| `label` | `String` | The name that will be printed above each item being synced. |
| `paths` | `Array` of `String` | Absolute or relative path to a folder or file. |
| `[excludedFiles]` | `String` | A space delimited list of file names or paths that won't be synced. |
| `[excludedFolders]` | `String` | A space delimited list of folders that won't be synced. |
| `[filters]` | `String` | Files or file types that will be synced. It uses [Robocopy's `File` syntax](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) for patterns. |
| `[recursive]` | `Boolean` | All syncs are recursive by default, but if you want to only copy top-level files, you would set this to `$false`. |

---

## Creating a shortcut to the script

- Right-click `moving-time.ps1` and select **Create Shortcut**
- Right-click the new shortcut and select **Properties**
- Change **Target** to `%WINDIR%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File ".\moving-time.ps1"`. If you want to have the
shortcut in another location other than this folder, change `.\moving-time.ps1`
to be the absolute path of the file. 
- Click the **Change Icon** button, navigate to this folder and select
`assets/app.ico`.

Now you can just double click the shortcut and it'll run via Powershell.

---

## Notes

- Generated `.ico` file via https://redketchup.io/icon-editor
- Got the icon from https://www.synology.com/zh-tw/dsm/packages/ActiveBackup
- Used this online tool to flesh out the GUI https://poshgui.com/Editor
