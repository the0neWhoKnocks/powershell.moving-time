@{
  bagPath = ".\example\output"
  itemsList = @(
    @{
      label = "New Music"
      paths = @(".\example\source\Music\Album 01")
    },
    @{
      label = "Music Playlists"
      paths = @(".\example\source\Music")
      recursive = $false
      filters = "*.m3u"
    },
    @{
      label = "Multi-path"
      paths = @(
        ".\example\source\Multi\folder1",
        ".\example\source\Multi\folder2"
      )
    },
    @{
      label = "Projects"
      paths = @(".\example\source\Projects")
      excludedFolders = "node_modules logs"
    }
  )
}
