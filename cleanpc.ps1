# This shoudl only be run for testing. It will stop the gradle daemon and then nuke and info
# gradle and android might have created, so we can have a fresh install
Set-Location "C:\Package\gradle-6.3-all\gradle-6.3\bin"

.\gradle --stop

# Sleep 10 seconds to make sure the gradle daemon stops
Start-Sleep 10

Set-Location "$HOME"
Remove-Item ".\.gradle" -Recurse -Force
Remove-Item ".\.android" -Recurse -Force
Remove-Item ".\.AndroidStudio3.6" -Recurse -Force