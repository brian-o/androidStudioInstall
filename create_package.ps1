[CmdletBinding()]
param (
    [switch]$small = $false,
    [switch]$noOfflineComponents = $false,
    [string]$output_root = "C:\Package\",
    [switch]$test_mode = $false
)
begin {
  # This is where we want to output the results of our scripts so it can easily be copied to other machines
  # ensure output root has '\' at the end of it
  if ($output_root -notmatch '\\$') {
      $output_root += '\'
  }
  $start_location = Get-Location

  # Declare the URLS for what we want to download here. If they need to be changed for new versions, this is the place to do so
  # $android_studio = "android-studio-ide-192.6392135-windows"
  $android_studio = "android-studio-ide-202.7486908-windows"
  $android_studio_filename = $output_root + "$($android_studio).zip"
  $android_studio_folder = $output_root + "$($android_studio)\"

  $gradle_6_3 = "gradle-6.3"
  $gradle_6_7 = "gradle-6.7.1"
  $gradle_7_0 = "gradle-7.0.2"

  $javahome = $android_studio_folder + "android-studio\jre"

  # Start Function Definitions
  function Write-IntroText {
    param (
      $small,
      $noOfflineComponents,
      $output_root
    )
    if ($small) {
      Write-Output "This run will build a small Version of sdk"
    } else {
      Write-Output "This run will build a full verison of the sdk"
    }
    if ($noOfflineComponents) {
      Write-Output "This run will not download offline maven, or android gradle"
    } else {
      Write-Output "This run will download all offline components"
    }

    Write-Output "This run will place the outputs in $output_root"

    $warning_text = (
      "WARNING *******************************************************************`r`n" +
      "This script checks if certain folders exists to skip having to download files multiple times. " +
      "If you think a file was not copmletely downloaded, make sure it is deleted or the script may not work properly. " +
      "This is especially true for the sdk. " +
      "maven_downloaded.txt and plugin_downloaded.txt are files that exist to let the script downloading " +
      "The offline maven and gradle plugin since the original files get merged into m2. " +
      "If you need those downloaded again, delete those 2 text files. " +
      "This script works best if this is the first run on a system. " +
      "Failure to use this script properly will prevent you from being able to deploy on the target machine " +
      "If you have any doubts about your package, run the cleanpc.ps1 and then delete the Package folder " +
      "End Warning **********************************************************************`r`n"
    )
    Write-Output $warning_text
    
  }

  function New-OutputDirectoryIfNeeded {
    param (
      $output_root
    )
    if(!(Test-Path $output_root)) {
      mkdir $output_root
    } else {
      Write-Output "$($output_root) already exists. Skipping..."
    }
  }

  function Set-TemporaryJavaHome {
    param (
      $javahome
    )
    $env:JAVA_HOME = $javahome
    Write-Output "JavaHome set to $env:JAVA_HOME"
    Write-Output "This will not persist after this powershell session ends"
  }

  function Get-AndroidxTracing {
    param (
    )
    $tracing_download_url = "https://dl.google.com/dl/android/maven2/androidx/tracing/tracing/1.0.0/tracing-1.0.0.aar"
    $tracing_destination = "$($output_root)m2\androidx\tracing\tracing\1.0.0\tracing-1.0.0.aar"
    if(![System.IO.File]::Exists($tracing_destination)) {
      $tracingWebClient = New-Object System.Net.WebClient
      $tracingWebClient.DownloadFile($tracing_download_url, $tracing_destination)
    }
  }

  function Get-Aapt2WindowsJar {
    param (
    )
    $aapt_url = "https://dl.google.com/android/maven2/com/android/tools/build/aapt2/4.2.2-7147631/aapt2-4.2.2-7147631-windows.jar"
    $aapt_destination = "$($output_root)m2\com\android\tools\build\aapt2\4.2.2-7147631\aapt2-4.2.2-7147631-windows.jar"
    if(![System.IO.File]::Exists($aapt_destination)) {
      $aaptWebClient = New-Object System.Net.WebClient
      $aaptWebClient.DownloadFile($aapt_url, $aapt_destination)
    }
  }

}
process {
  Write-IntroText -small $small -noOfflineComponents $noOfflineComponents -output_root $output_root
  New-OutputDirectoryIfNeeded -output_root $output_root

  $Jobs = @()
  $currentLocation = Get-Location
  $Jobs += Start-Job -FilePath .\scripts\get_android_studio.ps1 -ArgumentList $output_root,$android_studio
  $Jobs += Start-Job -FilePath .\scripts\get_gradle.ps1 -ArgumentList $output_root,$gradle_6_7
  $Jobs += Start-Job -FilePath .\scripts\copy_initial_files.ps1 -ArgumentList $currentLocation,$output_root

  # Wait for all the Current Jobs
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

  # start offline componenents so
  $offlineComponentsJob = Start-Job -FilePath .\scripts\get_offline_components.ps1 -ArgumentList $output_root

  Set-TemporaryJavaHome -javahome $javahome
  # move to the output location
  Set-Location $output_root
  & ".\scripts\get_sdk.ps1" -destination $output_root -pathToLicenses "$($start_location)\licenses" -sdkConfigPath "$($output_root)\sdkconfigs\smallsdk.conf" -javaHome $javahome
  # DownloadGradlePlugin

  $gradlePath = "$($output_root)$($gradle_6_7)-all\$($gradle_6_7)\bin\gradle.bat"

  & ".\scripts\build_m2_from_project.ps1" -destination $output_root -javahome $javahome -gradlePath $gradlePath -targetProjectPath "$($output_root)DepProject"
  & ".\scripts\build_m2_from_project.ps1" -destination $output_root -javahome $javahome -gradlePath $gradlePath -targetProjectPath "$($output_root)DepProjectKotlin"


  $stopGradle = "$($gradlePath) -D org.gradle.java.home=$javahome --stop"
  Invoke-Expression $stopGradle

  Get-AndroidxTracing
  Get-Aapt2WindowsJar

  Wait-Job $offlineComponentsJob
  if ($offlineComponentsJob.State -eq 'Failed') {
    Write-Output ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Red
    $didJobsFail = $true
  }
  if ($didJobsFail) {
    exit -1
  }
}
end {
  # Cleanup
  Set-Location $output_root  
  if((Test-Path .\DepProject\)) {
      Remove-Item .\DepProject -Recurse -Force
  }
  if((Test-Path .\DepProjectKotlin\)) {
      Remove-Item .\DepProjectKotlin -Recurse -Force
  }
  Set-Location $start_location
}



