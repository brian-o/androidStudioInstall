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

  $web_client = New-Object System.Net.WebClient

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

  function New-M2FromProjectDependencies {
    param (
      $gradle
    )
    Set-Location $output_root
    Set-Location .\DepProject
    # ..\gradle-6.3-all\gradle-6.3\bin\gradle.bat -D org.gradle.java.home=$javahome buildRepo -P outputRoot="$($output_root)m2"
    $buildRepo = "..\$($gradle)-all\$($gradle)\bin\gradle.bat -D org.gradle.java.home=$javahome buildRepo -P outputRoot=$($output_root)m2"
    Invoke-Expression $buildRepo
    # ..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome --stop

    Set-Location $output_root
    Set-Location .\DepProjectKotlin
    Invoke-Expression $buildRepo
    # ..\gradle-6.3-all\gradle-6.3\bin\gradle.bat -D org.gradle.java.home=$javahome buildRepo -P outputRoot="$($output_root)m2"
    # "..\$($gradle)-all\$($gradle)\bin\gradle.bat" -D org.gradle.java.home=$javahome buildRepo -P outputRoot="$($output_root)m2"
  }

  function Get-AndroidxTracing {
    param (
    )
    $tracing_download_url = "https://dl.google.com/dl/android/maven2/androidx/tracing/tracing/1.0.0/tracing-1.0.0.aar"
    $tracing_destination = "C:\Package\m2\androidx\tracing\tracing\1.0.0\tracing-1.0.0.aar"
    $web_client.DownloadFile($tracing_download_url, $tracing_destination)
  }

  function Get-Aapt2WindowsJar {
    param (
    )
    $web_client.DownloadFile(
      "https://dl.google.com/android/maven2/com/android/tools/build/aapt2/4.2.2-7147631/aapt2-4.2.2-7147631-windows.jar",
      "C:\Package\m2\com\android\tools\build\aapt2\4.2.2-7147631\aapt2-4.2.2-7147631-windows.jar"
    )
  }

}
process {
  Write-IntroText -small $small -noOfflineComponents $noOfflineComponents -output_root $output_root
  New-OutputDirectoryIfNeeded -output_root $output_root

  $Jobs = @()
  $currentLocation = Get-Location
  $offlineComponentsJob = Start-Job -FilePath .\scripts\get_offline_components.ps1 -ArgumentList $output_root
  $Jobs += Start-Job -FilePath .\scripts\get_android_studio.ps1 -ArgumentList $output_root,$android_studio
  $Jobs += Start-Job -FilePath .\scripts\get_gradle.ps1 -ArgumentList $output_root,$gradle_6_7
  $Jobs += Start-Job -FilePath .\scripts\copy_initial_files.ps1 -ArgumentList $currentLocation,$output_root

  # Wait for all the Current Jobs
  Wait-Job -Job $Jobs
  $didJobsFail = $false
  foreach ($job in $jobs) {
    if ($job.State -eq 'Failed') {
      Write-Host ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Red
      $didJobsFail = $true
    }
  }

  if ($didJobsFail) {
    exit -1
  }

  Set-TemporaryJavaHome -javahome $javahome
  # move to the output location
  Set-Location $output_root
  & "$PSScriptRoot\scripts\get_sdk.ps1" -destination $output_root -pathToLicenses "$($start_location)\licenses" -sdkConfigPath "$($output_root)\sdkconfigs\smallsdk.conf" -javaHome $javahome
  # DownloadGradlePlugin

  Wait-Job $offlineComponentsJob
  if ($offlineComponentsJob.State -eq 'Failed') {
    Write-Host ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Red
    $didJobsFail = $true
  }
  if ($didJobsFail) {
    exit -1
  }

  # Copy-AndroidStudioConfiguration -destination $output_root -android_studio_version $version
  New-M2FromProjectDependencies -gradle $gradle_6_7
  Get-AndroidxTracing
  Get-Aapt2WindowsJar
}
end {
  # Cleanup
  Set-Location $output_root
  if((Test-Path $android_studio_filename)) {
      Remove-Item $android_studio_filename
  }
  if((Test-Path $offline_maven_filename)) {
      Remove-Item $offline_maven_filename
  }
  if((Test-Path .\DepProject\)) {
      Remove-Item .\DepProject -Recurse -Force
  }
  if((Test-Path .\DepProjectKotlin\)) {
      Remove-Item .\DepProjectKotlin -Recurse -Force
  }
  Set-Location $start_location
}














