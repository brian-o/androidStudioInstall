param (
  $destination,
  $javahome,
  $gradlePath,
  $targetProjectPath
)
if ($destination -notmatch '\\$') {
  $destination += '\'
}
$startingDir = Get-Location

Set-Location $targetProjectPath
$buildRepo = "$($gradlePath) -D org.gradle.java.home=$javahome buildRepo -P outputRoot=$($destination)m2"
Invoke-Expression $buildRepo

Set-Location $startingDir