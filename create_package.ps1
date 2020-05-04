# This is where we want to output the results of our scripts so it can easily be copied to other machines
$output_root = "C:\Package\"
mkdir $output_root

# Copy project and install script to destination package
robocopy .\DepProject\ "C:\Package\DepProject" /e
robocopy .\DepProjectKotlin\ "C:\Package\DepProjectKotlin" /e
# Copy-Item -Path .\DepProject -Destination "C:\Package\DepProject" -Recurse
# robocopy .\install_package.ps1 "C:\Package"
Copy-Item -Path .\install_package.ps1 -Destination "C:\Package\"
robocopy .\.AndroidStudio3.6\ "C:\Package\.AndroidStudio3.6" /e
# Copy-Item -Path .\.AndroidStudio3.6 -Destination "C:\Package\.AndroidStudio3.6" -Recurse

# move to the output location
Set-Location $output_root
# Declare the URLS for what we want to download here. If they need to be changed for new versions, this is the place to do so
$android_studio_url = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.3.0/android-studio-ide-192.6392135-windows.zip"
$android_studio_filename = $output_root + "android-studio-ide-192.6392135-windows.zip"
$android_studio_folder = $output_root + "android-studio-ide-192.6392135-windows"


$gradle_url = "https://services.gradle.org/distributions/gradle-6.3-all.zip"
$gradle_filename = $output_root + "gradle-6.3-all.zip"
$gradle_folder = $output_root + "gradle-6.3-all"
$gradle = $gradle_folder + "\gradle-6.3\bin\gradle"

$gradle_plugin_url = "https://dl.google.com/android/studio/plugins/android-gradle/preview/offline-android-gradle-plugin-preview.zip"
$gradle_plugin_filename = $output_root + "offline-android-gradle-plugin-preview.zip"
$gradle_plugin_folder = $output_root + "offline-android-gradle-plugin-preview"

$offline_maven_url = "https://dl.google.com/android/studio/maven-google-com/stable/offline-gmaven-stable.zip"
$offline_maven_filename = $output_root + "offline-gmaven-stable.zip"
$offline_maven_folder = $output_root + "offline-gmaven-stable"

$command_line_tools_url = "https://dl.google.com/android/repository/commandlinetools-win-6200805_latest.zip"
$command_line_tools_filename = $output_root + "commandlinetools-win-6200805_latest.zip"
$command_line_tools_folder = $output_root + "commandlinetools-win-6200805_latest"

# Set javahome for the sdk
$javahome = $android_studio_folder + "\android-studio\jre"
$env:JAVA_HOME = $javahome
Write-Output "JavaHome set to $env:JAVA_HOME"
Write-Output "This will not persist after this powershell session ends"

$web_client = New-Object System.Net.WebClient
Write-Output "Downloading $android_studio_url"
$web_client.DownloadFile($android_studio_url, $android_studio_filename)
Write-Output "Unzipping $android_studio_filename"
Expand-Archive -Path $android_studio_filename -DestinationPath $android_studio_folder -Force


# Now download the command line tools so we can download the sdk
# This command should block until it is complete
Write-Output "Downloading $command_line_tools_url"

$web_client.DownloadFile($command_line_tools_url, $command_line_tools_filename)
Write-Output "Unzipping $command_line_tools_filename"
Expand-Archive -Path $command_line_tools_filename -DestinationPath $command_line_tools_folder -Force

# will manually need to accept the licenses
$sdkman = $command_line_tools_folder + "\tools\bin\sdkmanager.bat"

# basic sdk install
# & "$sdkman" --sdk_root="Sdk" "add-ons;addon-google_apis-google-24" "build-tools;29.0.3" "cmdline-tools;latest" "docs" "emulator" "extras;android;gapid;3" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" "extras;google;simulators" "extras;google;usb_driver" "extras;google;webdriver" "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "lldb;3.1" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"

# extra sdk install
# & "$sdkman" --sdk_root="Sdk" "build-tools;24.0.3" "build-tools;30.0.0-rc2" "extras;intel;Hardware_Accelerated_Execution_Manager" "ndk-bundle" "ndk;20.1.5948944" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-28" "platforms;android-R" "sources;android-24" "sources;android-25" "sources;android-26" "sources;android-27" "sources;android-28" "system-images;android-29;default;x86_64" "system-images;android-29;google_apis;x86_64"

# full sdk install so you only have to accept the set of licenses once
& "$sdkman" --sdk_root="Sdk" "add-ons;addon-google_apis-google-24" "build-tools;29.0.3" "cmdline-tools;latest" "docs" "emulator" "extras;android;gapid;3" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" "extras;google;simulators" "extras;google;usb_driver" "extras;google;webdriver" "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "lldb;3.1" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29" "build-tools;24.0.3" "build-tools;30.0.0-rc2" "extras;intel;Hardware_Accelerated_Execution_Manager" "ndk-bundle" "ndk;20.1.5948944" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-28" "platforms;android-R" "sources;android-24" "sources;android-25" "sources;android-26" "sources;android-27" "sources;android-28" "system-images;android-29;default;x86_64" "system-images;android-29;google_apis;x86_64"

# After downloading the sdk we don't need these anymore
Remove-Item $command_line_tools_filename
Remove-Item $command_line_tools_folder -Recurse

Write-Output "Downloading $gradle_plugin_url"
$web_client.DownloadFile($gradle_plugin_url, $gradle_plugin_filename)
Write-Output "Unzipping $gradle_plugin_filename"
Expand-Archive -Path $gradle_plugin_filename -DestinationPath "C:\Package\temp" -Force
Set-Location "C:\Package\temp\*"
robocopy * "C:\Package\m2" /e /move
# Move-Item -Path * -Destination "C:\Package\m2" -Force
Set-Location $output_root
Remove-Item "C:\Package\temp" -Recurse -Force

Write-Output "Downloading $offline_maven_url"
$web_client.DownloadFile($offline_maven_url, $offline_maven_filename)
Write-Output "Unzipping $offline_maven_filename"
Expand-Archive -Path $offline_maven_filename -DestinationPath "C:\Package\temp" -Force
Set-Location "C:\Package\temp\*"
robocopy * "C:\Package\m2" /e /move
# Move-Item -Path * -Destination "C:\Package\m2"
Set-Location $output_root
Remove-Item "C:\Package\temp" -Recurse -Force

# Now download gradle. Create a wrapper and run a task that can "build" the android project and cache the dependencies
Write-Output "Downloading $gradle_url"
$web_client.DownloadFile($gradle_url, $gradle_filename)
Write-Output "Unzipping $gradle_filename"
Expand-Archive -Path $gradle_filename -DestinationPath $gradle_folder -Force


Set-Location .\DepProject
..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome buildRepo
# ..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome --stop

Set-Location $output_root
Set-Location .\DepProjectKotlin
..\gradle-6.3-all\gradle-6.3\bin\gradle -D org.gradle.java.home=$javahome buildRepo

Set-Location $output_root
Remove-Item $android_studio_filename
Remove-Item $offline_maven_filename
Remove-Item $gradle_plugin_filename
Remove-Item .\DepProject -Recurse -Force
Remove-Item .\DepProjectKotlin -Recurse -Force