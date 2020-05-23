param (
    [switch]$small = $false,
    [switch]$noOfflineComponents = $false,
    [string]$output_root = "C:\Package\"
)
# This is where we want to output the results of our scripts so it can easily be copied to other machines
# ensure output root has '\' at the end of it
if ($output_root -notmatch '\\$') {
    $output_root += '\'
}

if ($small) {
    Write-Output "This run will build a small Version of sdk"
}
else {
    Write-Output "This run will build a full verison of the sdk"
}
if ($noOfflineComponents) {
    Write-Output "This run will not download offline maven, or android gradle"
}
else {
    Write-Output "This run will download all offline components"
}
Write-Output "This run will place the outputs in $output_root"

Write-Output "WARNING *******************************************************************\n\r\n\r"
Write-Output "This script checks if certain folders exists to skip having to download files multiple times"
Write-Output "If you think a file was not copmletely downloaded, make sure it is deleted or the script may not work properly."
Write-Output "This is especially true for the sdk."
Write-Output "maven_downloaded.txt and plugin_downloaded.txt are files that exist to let the script downloading"
Write-Output "The offline maven and gradle plugin since the original files get merged into m2."
Write-Output "If you need those downloaded again, delete those 2 text files."
Write-Output "This script works best if this is the first run on a system."
Write-Output "Failure to use this script properly will preven you from being able to deploy on the target machine"
Write-Output "If you have any doubts about your package, run the cleanpc.ps1 and then delete the Package folder"
Write-Output "End Warning **********************************************************************\n\r\n\r"

$start_location = Get-Location
if(!(Test-Path $output_root)) {
    mkdir $output_root
}
else {
    Write-Output "$($output_root) already exists. Skipping..."
}


# Copy project and install script to destination package
robocopy .\DepProject\ "$($output_root)DepProject" /e
robocopy .\DepProjectKotlin\ "$($output_root)DepProjectKotlin" /e
# Copy-Item -Path .\DepProject -Destination "$($output_root)DepProject" -Recurse
# robocopy .\install_package.ps1 "$($output_root)"
if(![System.IO.File]::Exists(".\install_package.ps1")) {
    Copy-Item -Path .\install_package.ps1 -Destination "$($output_root)"
} else {
    Write-Output "install_package.ps1 already exists. Skipping..."
}

robocopy .\.AndroidStudio3.6\ "$($output_root).AndroidStudio3.6" /e
# Copy-Item -Path .\.AndroidStudio3.6 -Destination "$($output_root).AndroidStudio3.6" -Recurse

# move to the output location
Set-Location $output_root
# Declare the URLS for what we want to download here. If they need to be changed for new versions, this is the place to do so
$android_studio_url = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.3.0/android-studio-ide-192.6392135-windows.zip"
$android_studio_filename = $output_root + "android-studio-ide-192.6392135-windows.zip"
$android_studio_folder = $output_root + "android-studio-ide-192.6392135-windows\"


$gradle_url = "https://services.gradle.org/distributions/gradle-6.3-all.zip"
$gradle_filename = $output_root + "gradle-6.3-all.zip"
$gradle_folder = $output_root + "gradle-6.3-all\"
# $gradle = $gradle_folder + "\gradle-6.3\bin\gradle"

$gradle_plugin_url = "https://dl.google.com/android/studio/plugins/android-gradle/preview/offline-android-gradle-plugin-preview.zip"
$gradle_plugin_filename = $output_root + "offline-android-gradle-plugin-preview.zip"
# $gradle_plugin_folder = $output_root + "offline-android-gradle-plugin-preview\"

$offline_maven_url = "https://dl.google.com/android/studio/maven-google-com/stable/offline-gmaven-stable.zip"
$offline_maven_filename = $output_root + "offline-gmaven-stable.zip"
# $offline_maven_folder = $output_root + "offline-gmaven-stable\"

$command_line_tools_url = "https://dl.google.com/android/repository/commandlinetools-win-6200805_latest.zip"
$command_line_tools_filename = $output_root + "commandlinetools-win-6200805_latest.zip"
$command_line_tools_folder = $output_root + "commandlinetools-win-6200805_latest\"

# Set javahome for the sdk
$javahome = $android_studio_folder + "\android-studio\jre"
$env:JAVA_HOME = $javahome
Write-Output "JavaHome set to $env:JAVA_HOME"
Write-Output "This will not persist after this powershell session ends"

$web_client = New-Object System.Net.WebClient

if(!(Test-Path $android_studio_folder)) {
    Write-Output "Downloading $android_studio_url"
    $web_client.DownloadFile($android_studio_url, $android_studio_filename)
    Write-Output "Unzipping $android_studio_filename"
    Expand-Archive -Path $android_studio_filename -DestinationPath $android_studio_folder -Force
} else {
    Write-Output "$android_studio_folder already exists. skipping..."
}


# Now download the command line tools so we can download the sdk
# This command should block until it is complete
if(!(Test-Path "$($output_root)Sdk")) {
    Write-Output "Downloading $command_line_tools_url"
    $web_client.DownloadFile($command_line_tools_url, $command_line_tools_filename)
    Write-Output "Unzipping $command_line_tools_filename"
    Expand-Archive -Path $command_line_tools_filename -DestinationPath $command_line_tools_folder -Force

    # will manually need to accept the licenses
    $sdkman = $command_line_tools_folder + "\tools\bin\sdkmanager.bat"

    # basic sdk install
    # & "$sdkman" --sdk_root="Sdk" "add-ons;addon-google_apis-google-24" "build-tools;29.0.3" "cmdline-tools;latest" "emulator" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" "extras;google;simulators" "extras;google;usb_driver" "extras;google;webdriver" "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"

    # extra sdk install
    # & "$sdkman" --sdk_root="Sdk" "build-tools;24.0.3" "build-tools;30.0.0-rc2" "extras;intel;Hardware_Accelerated_Execution_Manager" "ndk-bundle" "ndk;20.1.5948944" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-28" "platforms;android-R" "sources;android-24" "sources;android-25" "sources;android-26" "sources;android-27" "sources;android-28" "system-images;android-29;default;x86_64" "system-images;android-29;google_apis;x86_64"

    # only install current sdk if small is selected
    if ($small) {
        # basic sdk install
        Write-Output "y" | & "$sdkman" --sdk_root="Sdk" "add-ons;addon-google_apis-google-24" "build-tools;29.0.3" "cmdline-tools;latest" "emulator" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" "extras;google;simulators" "extras;google;usb_driver" "extras;google;webdriver" "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"

    }
    else {
        # full sdk install so you only have to accept the set of licenses once
        & "$sdkman" --sdk_root="Sdk" "add-ons;addon-google_apis-google-24" "build-tools;29.0.3" "cmdline-tools;latest" "emulator" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" "extras;google;simulators" "extras;google;usb_driver" "extras;google;webdriver" "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29" "build-tools;24.0.3" "build-tools;30.0.0-rc2" "extras;intel;Hardware_Accelerated_Execution_Manager" "ndk-bundle" "ndk;20.1.5948944" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-28" "platforms;android-R" "sources;android-24" "sources;android-25" "sources;android-26" "sources;android-27" "sources;android-28" "system-images;android-29;default;x86_64" "system-images;android-29;google_apis;x86_64"
    }

    # After downloading the sdk we don't need these anymore
    Remove-Item $command_line_tools_filename
    Remove-Item $command_line_tools_folder -Recurse
} else {
    Write-Output "sdk already exists. skipping..."
}

$plugin_flag_file = "$($output_root)plugin_downloaded.txt"
if($noOfflineComponents -or (Test-Path $plugin_flag_file)) {
    if ($noOfflineComponents) {
        Write-Output "No Offline Components flag set"
    }
    Write-Output "$gradle_plugin_filename appears to have been downloaded since $plugin_flag_file exists."
    Write-Output "Skipping operation. If this is an error, simply delete $pluging_flag_file"
} else {
    Write-Output "Downloading $gradle_plugin_url"
    Write-Output "Downloading $gradle_plugin_url" > $plugin_flag_file
    $web_client.DownloadFile($gradle_plugin_url, $gradle_plugin_filename)
    Write-Output "Unzipping $gradle_plugin_filename"
    Expand-Archive -Path $gradle_plugin_filename -DestinationPath "$($output_root)temp" -Force
    Set-Location "$($output_root)temp\*"
    robocopy .\ "$($output_root)m2" /e /move
    # Move-Item -Path * -Destination "$($output_root)m2" -Force
    Set-Location $output_root
    Remove-Item "$($output_root)temp" -Recurse -Force
}
Set-Location $output_root
$maven_flag_file = "$($output_root)maven_downloaded.txt"
if($noOfflineComponents -or (Test-Path $maven_flag_file)) {
    if ($noOfflineComponents) {
        Write-Output "No Offline Components flag set"
    }
    Write-Output "$offline_maven_filename appears to have been downloaded since $maven_flag_file exists."
    Write-Output "Skipping operation. If this is an error, simply delete $maven_flag_file"
} else {
    Write-Output "Downloading $offline_maven_url"
    Write-Output "Downloading $offline_maven_url" > $maven_flag_file
    $web_client.DownloadFile($offline_maven_url, $offline_maven_filename)
    Write-Output "Unzipping $offline_maven_filename"
    Expand-Archive -Path $offline_maven_filename -DestinationPath "$($output_root)temp" -Force
    Set-Location "$($output_root)temp\*"
    robocopy .\ "$($output_root)m2" /e /move
    # Move-Item -Path * -Destination "$($output_root)m2"
    Set-Location $output_root
    Remove-Item "$($output_root)temp" -Recurse -Force
}

Set-Location $output_root
# Now download gradle. Create a wrapper and run a task that can "build" the android project and cache the dependencies
if(!(Test-Path $gradle_filename)) {
    Write-Output "Downloading $gradle_url"
    $web_client.DownloadFile($gradle_url, $gradle_filename)
    
} else {
    Write-Output "$gradle_filename already exists. skipping...."
}
if(!(Test-Path $gradle_folder)) {
    Write-Output "Unzipping $gradle_filename"
    Expand-Archive -Path $gradle_filename -DestinationPath $gradle_folder -Force
} else {
    Write-Output "$gradle_folder already exists. Skipping..."
}


Set-Location $output_root
Set-Location .\DepProject
..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome buildRepo -P outputRoot="$($output_root)m2"
# ..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome --stop

Set-Location $output_root
Set-Location .\DepProjectKotlin
..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome buildRepo -P outputRoot="$($output_root)m2"

Set-Location $output_root
if((Test-Path $android_studio_filename)) {
    Remove-Item $android_studio_filename
}
if((Test-Path $offline_maven_filename)) {
    Remove-Item $offline_maven_filename
}
if((Test-Path $gradle_plugin_filename)) {
    Remove-Item $gradle_plugin_filename
}
if((Test-Path .\DepProject\)) {
    Remove-Item .\DepProject -Recurse -Force
}
if((Test-Path .\DepProjectKotlin\)) {
    Remove-Item .\DepProjectKotlin -Recurse -Force
}

Set-Location $start_location
