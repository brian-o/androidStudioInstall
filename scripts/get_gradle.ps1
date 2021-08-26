param (
  $destination,
  $gradle
)
if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location
Set-Location $destination

$gradle_url = "https://services.gradle.org/distributions/$($gradle)-all.zip"
$gradle_filename = $destination + "$($gradle)-all.zip"
$gradle_folder = $destination + "$($gradle)-all\"

Set-Location $destination
Write-Output "Downloading $gradle_url"
$gradleWebClient =New-Object System.Net.WebClient
$gradleWebClient.DownloadFile($gradle_url, $gradle_filename)

Write-Output "Unzipping $gradle_filename"
Expand-Archive -Path $gradle_filename -DestinationPath $gradle_folder -Force

Set-Location $startingDir