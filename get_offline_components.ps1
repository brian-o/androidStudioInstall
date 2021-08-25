param (
  $destination
)
if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location
Set-Location $destination

$offline_maven_url = "https://dl.google.com/android/studio/maven-google-com/stable/offline-gmaven-stable.zip"
$offline_maven_filename = $destination + "offline-gmaven-stable.zip"

Write-Output "Downloading $offline_maven_url"
$offlineComponentsWebClient = New-Object System.Net.WebClient
$offlineComponentsWebClient.DownloadFile($offline_maven_url, $offline_maven_filename)

Write-Output "Unzipping $offline_maven_filename"
Expand-Archive -Path $offline_maven_filename -DestinationPath "$($destination)temp" -Force

Set-Location "$($destination)temp\*"
robocopy .\ "$($destination)m2" /e /move

Set-Location $destination
Remove-Item "$($destination)temp" -Recurse -Force
Set-Location = $startingDir