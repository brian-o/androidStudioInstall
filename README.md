# androidStudioInstall

### CI Status
![CI](https://github.com/brian-o/androidStudioInstall/workflows/CI/badge.svg)

Project with scripts that can download everything needed to run android studio offline

Make sure you have plenty of hard drive space (~25GB) before running this. I don't know what will happen if you don't have enough space.

There are not progress bars on all the downloads, so if you think the script froze just be patient and wait for a little bit.

This script will check for existing files in C:\Package\ and won't download them again if they already exist. It doesn't do an in depth check though, so if the file is corrupted, delete it and it will be re-downloaded.

If all else fails delete everything in C:\Package\ and delete .android .androidStudio3.6 and .gradle inside of USER_HOME
then re-run the script

## How to use this project
1. Run the create_package.ps1 powershell script. You will have to accept sdk licenses so don't just abandon the script after starting it. Once the licenses are accepted the script can be left to do its job. These licenses will include the standard sdk license, the beta license, and the HAXM license.

2. Copy the folder C:\Package\ to the offline machine (reccommend zipping it before doing so (if using 7zip or some other faster zip tools) to increase transfer speed to/from the removable media.

3. On the offline computer run the install_package.ps1 script.

4. Open Android studio from studio64.exe located in C:\Package\android-studio-ide-192.6392135-windows\android-studio\bin
  (You may want to create a shortcut to this)
  
## Trouble shooting
1. Ensure you have manually set android studio to use the gradle in the package and not this local wrapper (you may have to do this for every project, but I am not sure)

2. Ensure you have added maven {url { "C:\\Package\\m2" }} to the repositories section and removed google() and jcenter()

3. Check that the application is using the right version of dependencies. (I've noticed that I sometimes need to upgrade to appcompat-1.1, because sometimes it defaults to 1.02)

## How to test this on a single machine

1. Run the create_package.ps1 powershell script. You will have to accept sdk licenses so don't just abandon the script after starting it. Once the licenses are accepted the script can be left to do its job. These licenses will include the standard sdk license, the beta license, and the HAXM license.


2. Run the cleanpc.ps1 powershell script (if there are any errors just go to Your User Home Folder, and ensure the following are deleted: ".android", ".AndroidStudio3.6", ".gradle")
These have caches in them, so we want to start clean to ensure things are working properly.

3. Turn on Airplane mode/ disconnect from the network

4. Run the install_package.ps1 powershell script.

5. Open Android studio from studio64.exe located in C:\Package\android-studio-ide-192.6392135-windows\android-studio\bin
  (You may want to create a shortcut to this)
