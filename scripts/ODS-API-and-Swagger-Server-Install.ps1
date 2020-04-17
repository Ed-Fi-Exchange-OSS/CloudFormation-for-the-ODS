Param([string]$DatabaseHost, [string]$DatabaseUser, [string]$DatabasePassword, [string]$DomainName, [string]$InstallSwagger, [string]$S3Bucket)

$DownloadsDirectory = 'C:\EdFiArtifacts'
$WebDeployInstallPackage = 'WebDeploy_amd64_en-US.msi'
$UrlRewriteInstallPackage = 'rewrite_amd64_en-US.msi'
$AppNameODSAPI = 'EdFi.Ods.WebApi'
$AppNameODSAPIPackage = 'EdFi.Ods.WebApi.zip'
$AppNameSwaggerUI = 'EdFi.Ods.SwaggerUI'
$AppNameSwaggerUIPackage = 'EdFi.Ods.SwaggerUI.zip'
$MSDeployExeDirectory = "C:\Program Files\IIS\Microsoft Web Deploy V3"
$LogFile = "EdFi-Install-Process.txt"
$TranscriptFile = "ods-api-swagger-transcript-log.txt"
$APIConfigTemplate = "Web.config.API-template"
$SwaggerConfigTemplate = "Web.config.Swagger-template"
$IISRootFolderName = "C:\inetpub\wwwroot"
$WebConfigFileName = 'Web.config'
$LogDirectory = "C:\EdFiInstallLogs"

if ( -not (Test-Path -Path $LogDirectory) ) {
    New-Item $LogDirectory -ItemType Directory
}


$ODSPackagePath = [Io.path]::Combine($DownloadsDirectory,$AppNameODSAPIPackage)
$SwaggerPackagePath = [Io.path]::Combine($DownloadsDirectory,$AppNameSwaggerUIPackage)
$WebDeployPackagePath = [Io.path]::Combine($DownloadsDirectory,$WebDeployInstallPackage)
$URLRewritePackagePath = [Io.path]::Combine($DownloadsDirectory,$UrlRewriteInstallPackage)
$ODSConfigTemplatePath = [Io.path]::Combine($DownloadsDirectory,$APIConfigTemplate)
$SwaggerConfigTemplatePath = [Io.path]::Combine($DownloadsDirectory,$SwaggerConfigTemplate)
$ODSWebConfigFilePath = [Io.path]::Combine($IISRootFolderName,$AppNameODSAPI,$WebConfigFileName)
$SwaggerWebConfigFilePath = [Io.path]::Combine($IISRootFolderName,$AppNameSwaggerUI,$WebConfigFileName)
$TranscriptFilePath = [Io.path]::Combine($LogDirectory,$TranscriptFile)
$LogFilePath = [Io.path]::Combine($LogDirectory,$LogFile)

Start-Transcript -Path "$TranscriptFilePath"

function LogMsg($Msg)
{
    Write-Host "$(Get-Date -format 'u') $Msg"
    Add-Content $LogFilePath "$(Get-Date -format 'u') $Msg `n"

}

LogMsg("Starting the setup of the ODS API Application Server...")

If ($InstallSwagger -eq 'yes') {
   LogMsg("SwaggerUI option equals yes, and will install at the end...")
} Else {
   LogMsg("SwaggerUI option not equal to yes.  SwaggerUI will not be installed...")
}

try
{
   ## Need to download EdFi Artficats from the publicly accessible S3 bucket for the Quick Deploy
   LogMsg("Downloading the EdFi ODS API Package...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$AppNameODSAPIPackage -LocalFile $ODSPackagePath
   LogMsg("Downloading the EdFi ODS API Package complete")

   LogMsg("Downloading the WebDeploy IIS Package...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$WebDeployInstallPackage -LocalFile $WebDeployPackagePath
   LogMsg("Downloading the WebDeploy Package complete")

   LogMsg("Downloading the URL Rewrite Module Package...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$UrlRewriteInstallPackage -LocalFile $URLRewritePackagePath
   LogMsg("Downloading the WebDeploy Package complete")

   LogMsg("Downloading the EdFi ODS API Config Template...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$APIConfigTemplate -LocalFile $ODSConfigTemplatePath
   LogMsg("Downloading the EdFi ODS API Config Template completed")
}
catch
{
   LogMsg("ERROR! Unable to download the required files from S3.  Please see the error below.")
   LogMsg("$error") 
   $error.Clear()	
   EXIT
}

### Begin Install Process
LogMsg("Installing the Servermanager module...")
Import-Module Servermanager

try
{
        LogMsg("Installing IIS with all subfeatures and management tool...this will take a few minutes.")
        Install-WindowsFeature -Name "Web-Server" -IncludeAllSubFeature -IncludeManagementTools
        LogMsg("IIS installed")
}
catch
{
	LogMsg("ERROR! IIS installation was unsuccessful")
	LogMsg("$error")
	$error.Clear()	
	EXIT
}

# Sleep just to be safe that IIS is online
Start-Sleep -s 10

LogMsg("Installing the URL Rewrite Module for IIS")
Start-Process "msiexec.exe" -ArgumentList "/i $DownloadsDirectory\$UrlRewriteInstallPackage /quiet" -Wait
LogMsg("URL Rewrite Module for IIS has been installed")
Start-Sleep -s 10

LogMsg("Installing the Web Deploy package for IIS...")
Start-Process "msiexec.exe" -ArgumentList "/i $DownloadsDirectory\$WebDeployInstallPackage /quiet" -Wait
LogMsg("Web Deploy for IIS has been installed")
Start-Sleep -s 10

for ($i = 0; $i -lt 10; $i++)
{
    if ( Test-Path -Path $MSDeployExeDirectory ) 
     {
        LogMsg("Installing the ODS/API application to IIS...")
        Set-Location $MSDeployExeDirectory
        .\msdeploy.exe -verb:sync -source:package="$DownloadsDirectory\$AppNameODSAPIPackage" -dest:auto
        LogMsg("ODS/API application installed as $AppNameODSAPI")
	LogMsg("Installation of ODS/API application to IIS completed.")
        Start-Sleep -s 20
        Break
     } 
    else 
     {
        LogMsg("The MS Deploy directoty is not yet available..waiting 20 seconds to try again and to install the ODS package...")
        Start-Sleep -s 20
     }
}

if ( Test-Path -Path $ODSConfigTemplatePath )
{
     LogMsg("Updating ODS API Web.Config file for environment...")
     $WebApiTextContent = Get-Content -Path "$ODSConfigTemplatePath" -Raw
     $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Ods"[^\\]*?\/>', "<add name=`"EdFi_Ods`" connectionString=`"Database=EdFi_Ods; Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Integrated Security=false`" providerName=`"System.Data.SqlClient`" />"
     $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Admin"[^\\]*?\/>', "<add name=`"EdFi_Admin`" connectionString=`"Database=EdFi_Admin; Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Integrated Security=false`" providerName=`"System.Data.SqlClient`" />"
     $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Security"[^\\]*?\/>', "<add name=`"EdFi_Security`" connectionString=`"Database=EdFi_Security; Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Integrated Security=false; Persist Security Info=true;`" providerName=`"System.Data.SqlClient`" />"
     $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_master"[^\\]*?\/>', "<add name=`"EdFi_master`" connectionString=`"Database=master; Data Source=Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Integrated Security=false`" providerName=`"System.Data.SqlClient`" />"
     Set-Content "$ODSConfigTemplatePath" $WebApiTextContent

     LogMsg("Copying new Web.config file into place for the ODS/API..")
     Copy-Item $ODSConfigTemplatePath -Destination $ODSWebConfigFilePath -Force
     LogMsg("Updated ODS API Config file for environment.")
}
else
{
     LogMsg("ERROR!  The $ODSConfigTemplatePath file does not exist.   This most likely means there was an issue using the configuration file template.")
     EXIT 

}

## Sleep to ensure that IIS Config files are ready to be edited as we have just installed some packages and edited configs for sites
Start-Sleep 30

### Install SwaggerUI if given the proper command line parameter
If ($InstallSwagger -eq 'yes') {

   LogMsg("Starting installation of SwaggerUI to IIS...")

   try 
     {
         LogMsg("Downloading the EdFi Swagger Package...")
         Copy-S3Object -BucketName $S3Bucket -Key packages/$AppNameSwaggerUIPackage -LocalFile $SwaggerPackagePath
         LogMsg("Downloading the EdFi SwaggerUI Package complete")

         LogMsg("Downloading the EdFi Swagger Config Template...")
         Copy-S3Object -BucketName $S3Bucket -Key packages/$SwaggerConfigTemplate -LocalFile $SwaggerConfigTemplatePath
         LogMsg("Downloading the EdFi Swagger Config Template completed")

         Start-Sleep -s 10
     
         LogMsg("Installing the SwaggerUI application to IIS...")
         Set-Location $MSDeployExeDirectory
         .\msdeploy.exe -verb:sync -source:package="$DownloadsDirectory\$AppNameSwaggerUIPackage" -dest:auto
         LogMsg("SwaggerUI application installed as $AppNameSwaggerUI")
         Start-Sleep -s 10

         ## Need update Swagger Config
         LogMsg("Updating SwaggerUI Web.Config file for environment...")
         $SwaggerTextContent = Get-Content -Path "$SwaggerConfigTemplatePath" -Raw
         $SwaggerTextContent = $SwaggerTextContent -Replace '<add key="swagger.webApiMetadataUrl"[^\\]*?\/>', "<add key=`"swagger.webApiMetadataUrl`" value=`"https://$DomainName/EdFi.Ods.WebApi/metadata/`"/>"
         $SwaggerTextContent = $SwaggerTextContent -Replace '<add key="swagger.webApiVersionUrl"[^\\]*?\/>', "<add key=`"swagger.webApiVersionUrl`" value=`"https://$DomainName/EdFi.Ods.WebApi/`"/>"
         Set-Content "$SwaggerConfigTemplatePath" $SwaggerTextContent

         LogMsg("Copying new Web.config file into place for the Swagger UI..")
         Copy-Item $SwaggerConfigTemplatePath -Destination $SwaggerWebConfigFilePath -Force
         LogMsg("Updated SwaggerUI Config file for environment.")

         Start-Sleep -s 5

         LogMsg("Installation of SwaggerUI to IIS completed.")
     }
   catch
     {
         LogMsg("ERROR!  SwaggerUI installation was unsuccessful")
	 LogMsg("$error")
	 $error.Clear()
     }  
}

## Sleep for 10 seconds in case this is a non-prod environment to allow the Admin App to start its install cleanly
Start-Sleep 10

LogMsg("SUCCESS! Application Server Setup Completed.")

