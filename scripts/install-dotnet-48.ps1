Param([string]$S3Bucket)

$DownloadsDirectory = 'C:\EdFiArtifacts'
$DotNetInstallEXE = 'ndp48-x86-x64-allos-enu.exe'
$LogFile = "EdFi-Install-Process.txt"
$TranscriptFile = "dotnet-48-install-transcript-log.txt"
$LogDirectory = "C:\EdFiInstallLogs"

if ( -not (Test-Path -Path $LogDirectory) ) {
    New-Item $LogDirectory -ItemType Directory
}


$EXEPackagePath = [Io.path]::Combine($DownloadsDirectory,$DotNetInstallEXE)
$TranscriptFilePath = [Io.path]::Combine($LogDirectory,$TranscriptFile)
$LogFilePath = [Io.path]::Combine($LogDirectory,$LogFile)

Start-Transcript -Path "$TranscriptFilePath"

function LogMsg($Msg)
{
    Write-Host "$(Get-Date -format 'u') $Msg"
    Add-Content $LogFilePath "$(Get-Date -format 'u') $Msg `n"

}

LogMsg("Installing DotNet v4.8...")

try
{
   ## Need to download EdFi Artficats from the publicly accessible S3 bucket for the Quick Deploy
   LogMsg("Downloading the DotNet Installer Package...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$DotNetInstallEXE -LocalFile $EXEPackagePath
   LogMsg("Downloading the DotNet Installer Package complete")
}
catch
{
   LogMsg("ERROR! Unable to download the required files from S3.  Please see the error below.")
   LogMsg("$error") 
   $error.Clear()	
   EXIT
}

try
{
   LogMsg("Starting installation of DotNet 4.8 ....")
   Start-Process -FilePath $EXEPackagePath -ArgumentList "/q /norestart"
   Start-Sleep 60
   LogMsg("Installation of DotNet v4.8 complete")

}
catch
{
   LogMsg("ERROR! Unable to install DotNet v4.8.  Please see the error below.")
   LogMsg("$error") 
   $error.Clear()	
   EXIT
}


