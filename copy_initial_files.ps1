param(
  $sourceDir,
  $destination
)

function Copy-GradleProjects {
  param (
    $destination
  )
  Write-Output "Copy gradle projects to $destination"
  robocopy .\DepProject\ "$($destination)DepProject" /e
  robocopy .\DepProjectKotlin\ "$($destination)DepProjectKotlin" /e 
}

function Copy-InstallScript {
  param (
    $destination
  )
  Write-Output "Copy Install script to $destination"
  if(![System.IO.File]::Exists(".\install_package.ps1")) {
    Copy-Item -Path .\install_package.ps1 -Destination "$($destination)"
  } else {
    Write-Output "install_package.ps1 already exists. Skipping..."
  }
}

function Copy-SdkConfigurations {
  param (
    $destination
  )
  Write-Output "Copy Sdk Configurations To $destination"
  robocopy .\sdkconfigs\ "$($destination)sdkconfigs" /e
}

if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location
Set-Location $sourceDir
Copy-GradleProjects -destination $destination
Copy-InstallScript -destination $destination
Copy-SdkConfigurations -destination $destination
Set-Location $startingDir
  