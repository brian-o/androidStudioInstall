# androidStudioInstall

### CI Status
![CI](https://github.com/brian-o/androidStudioInstall/workflows/CI/badge.svg)

Project with scripts that can download everything needed to run android studio offline

Make sure you have plenty of hard drive space (~25GB) before running this. I don't know what will happen if you don't have enough space.

There are not progress bars on all the downloads, so if you think the script froze just be patient and wait for a little bit.

If all else fails delete everything in C:\Package\ and delete .android and .gradle inside of USER_HOME then re-run the script

## How to use this project
1. Run the create_package.ps1 powershell script. SDK licenses are accepted automatically. These licenses will include the standard sdk license, the beta license, and the HAXM license.

2. Copy the folder C:\Package\ to the offline machine (reccommend zipping it before doing so (if using 7zip or some other faster zip tools) to increase transfer speed to/from the removable media.

4. Open Android studio from studio64.exe located in C:\Package\android-studio-ide-202.7486908-windows\android-studio\bin
  (You may want to create a shortcut to this)
  
## Trouble shooting
1. Ensure you have manually set android studio to use the gradle in the package and not this local wrapper (you may have to do this for every project, but I am not sure)

2. Ensure the SDK for the project is set either with local.properties or by setting the SDK location in Android Studio

3. Ensure you have added maven {url { "C:\\Package\\m2" }} to the repositories section and removed google() and jcenter()

4. Check that the application is using the right version of dependencies. 

## How to test this on a single machine

1. Run the create_package.ps1 powershell script. SDK licenses are accepted automatically. These licenses will include the standard sdk license, the beta license, and the HAXM license.

2. Delete caches for android and gradle. Go to Your User Home Folder, and ensure the following are deleted: [".android", ".gradle"]. Also delete any caches in the desired project.

3. Turn on Airplane mode or disconnect from the network

5. Open Android studio from studio64.exe located in C:\Package\android-studio-ide-202.7486908-windows\android-studio\bin
  (You may want to create a shortcut to this)
