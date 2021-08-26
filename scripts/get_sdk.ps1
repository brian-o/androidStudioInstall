param (
  $destination,
  $javaHome,
  $pathToLicenses,
  $sdkConfigPath
)
if ($pathToLicenses -notmatch '\\$') {
  $pathToLicenses += '\'
}
if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location
Set-Location $destination

$sdkRoot = "$($destination)Sdk\"
Write-Output "Writing SDK to $sdkRoot"

# function Get-SdkComponent {
#   param (
#     $sdkManager,
#     [string]$componentName,
#     [string]$sdkRoot
#   )
#   Write-Output "y"| & "$sdkManager" --sdk_root=$sdkRoot $componentName
# }

$env:JAVA_HOME = $javaHome
Write-Output "JavaHome set to $env:JAVA_HOME"
Write-Output "This will not persist after this powershell session ends"

$command_line_tools = "commandlinetools-win-7302050_latest"
$command_line_tools_url = "https://dl.google.com/android/repository/$($command_line_tools).zip"
$command_line_tools_filename = $destination + "$($command_line_tools).zip"
$command_line_tools_folder = $destination + "$($command_line_tools)\"

# Now download the command line tools so we can download the sdk
# This command should block until it is complete

Write-Output "Downloading $command_line_tools_url"
$web_client = New-Object System.Net.WebClient
$web_client.DownloadFile($command_line_tools_url, $command_line_tools_filename)
Write-Output "Unzipping $command_line_tools_filename"
Expand-Archive -Path $command_line_tools_filename -DestinationPath $command_line_tools_folder -Force

# will manually need to accept the licenses
$sdkman = $command_line_tools_folder + "cmdline-tools\bin\sdkmanager.bat"

Write-Output "y"| & "$sdkman" --sdk_root=$sdkRoot --update
Write-Output "y"| & "$sdkman" --sdk_root=$sdkRoot --licenses 

robocopy "$($pathToLicenses)" "$($sdkRoot)licenses\" /e
Write-Output "y"| & "$sdkman" --sdk_root=$sdkRoot --licenses

# $components = Get-Content -Path "$sdkConfigPath"
# ForEach ($component in $components) {
#   Get-SdkComponent -sdkManager $sdkMan -sdkRoot $sdkRoot -componentName $component
# }

$Jobs = @()
$sdkScriptBlock = {
  param(
    $javaHome,
    $sdkRoot,
    $sdkman,
    $component
  )
  function Get-SdkComponent {
    param (
      $sdkManager,
      [string]$componentName,
      [string]$sdkRoot
    )
    Write-Output "y"| & "$sdkManager" --sdk_root=$sdkRoot $componentName
  }
  $env:JAVA_HOME = $javaHome
  Write-Output "JavaHome set to $env:JAVA_HOME"
  Write-Output "This will not persist after this powershell session ends"
  Get-SdkComponent -sdkManager $sdkman -sdkRoot $sdkRoot -componentName $component
}
$components = Get-Content -Path "$sdkConfigPath"
ForEach ($component in $components) {
  $Jobs += Start-Job -ScriptBlock $sdkScriptBlock -ArgumentList $javaHome,$sdkRoot,$sdkman,$component
}
Wait-Job -Job $Jobs
$didJobsFail = $false
foreach ($job in $jobs) {
  if ($job.State -eq 'Failed') {
    Write-Output ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Red
    $didJobsFail = $true
  }
}

if ($didJobsFail) {
  exit -1
}


robocopy "$($pathToLicenses)" "$($destination)licenses\" /e
Write-Output "y"| & "$sdkman" --sdk_root=$sdkRoot --licenses
      

Set-Location $startingDir