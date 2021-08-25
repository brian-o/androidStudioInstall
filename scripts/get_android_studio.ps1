param (
  $destination,
  $android_studio
)
if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location
Set-Location $destination

$android_studio_url = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.2.2.0/$($android_studio).zip"
$android_studio_filename = $destination + "$($android_studio).zip"
$android_studio_folder = $destination + "$($android_studio)\"

Write-Output "Downloading $android_studio_url"
$androidWebClient = New-Object System.Net.WebClient
$androidWebClient.DownloadFile($android_studio_url, $android_studio_filename)
Write-Output "Unzipping $android_studio_filename"
Expand-Archive -Path $android_studio_filename -DestinationPath $android_studio_folder -Force

if((Test-Path $android_studio_filename)) {
  Remove-Item $android_studio_filename
}

Set-Location $startingDir