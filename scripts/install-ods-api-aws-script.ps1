Param([string]$DatabaseHost, 
      [string]$DatabaseUser, 
      [string]$DatabasePassword,
      [string]$DBEngine,
      [string]$DomainName, 
      [string]$InstallSwagger, 
      [string]$S3Bucket,
      [string]$VersionNumber
)

$ErrorActionPreference = "Stop"

##### Variables #########
$LogDirectory = "C:\EdFiInstallLogs"
$DownloadsDirectory = "C:\EdFiArtifacts"
$MSDeployExeDirectory = "C:\Program Files\IIS\Microsoft Web Deploy V3"
$TranscriptFilePath = [Io.path]::Combine($LogDirectory,"ods-api-swagger-install-transcript.txt")

Start-Transcript -Path "$TranscriptFilePath"

function LogMsg($Msg) {
    Write-Host "$(Get-Date -format 'u') $Msg"
}


function Download-Edfi-Artifacts {
   
    Param(    
        [parameter(position=0)]
        [string] $filename,
        [parameter(position=1)]
        [string] $version  
    )
 
    $OutputFile = (Join-Path $DownloadsDirectory $filename)    

    $packageSource = "https://odsassets.blob.core.windows.net/public/CloudOds/deploy/release/$version/$filename"

    LogMsg("Downloading file from $packageSource")
  
    Invoke-WebRequest $packageSource -OutFile $OutputFile  
    
    return $OutputFile
   
}

function Install-IIS {
    
    Import-Module Servermanager

    try {
        LogMsg("Installing IIS with all subfeatures and management tool...this will take a few minutes.")
        Install-WindowsFeature -Name "Web-Server" -IncludeAllSubFeature -IncludeManagementTools
        LogMsg("-------------- IIS installed successfully --------------------")
    }
    catch {
	    LogMsg("-------------------ERROR! IIS installation was unsuccessful------------------------")
	    LogMsg("$error")
	    EXIT
    }


}

function Install-IISUrlRewriteModule {
  
    $UrlRewriteInstallPackage = "rewrite_amd64_en-US.msi"
    $URLRewritePackagePath = (Join-Path $DownloadsDirectory $UrlRewriteInstallPackage)

    LogMsg("Downloading IIS Rewrite Module from the EdFi S3 bucket $S3Bucket")
    Copy-S3Object -BucketName $S3Bucket -Key packages/$UrlRewriteInstallPackage -LocalFile $URLRewritePackagePath
    LogMsg("Downloading the IIS Rewrite Module Package from S3 completed.")

    LogMsg("Installing IIS URL Rewrite Module.")
    Start-Process "msiexec.exe" -ArgumentList "/i $DownloadsDirectory\$UrlRewriteInstallPackage /quiet" -Wait
    LogMsg("Installation of URL Rewrite Module is complete.")

}

function Install-IISWebDeployModule {

    $WebDeployInstallPackage = "WebDeploy_amd64_en-US.msi"
    $WebDeployPackagePath = (Join-Path $DownloadsDirectory $WebDeployInstallPackage)

    LogMsg("Downloading the WebDeploy IIS Package.")
    Copy-S3Object -BucketName $S3Bucket -Key packages/$WebDeployInstallPackage -LocalFile $WebDeployPackagePath
    LogMsg("Downloading the WebDeploy Package from completed.")

    LogMsg("Installing the Web Deploy package for IIS.")
    try {
      Start-Process "msiexec.exe" -ArgumentList "/i $WebDeployPackagePath /quiet" -Wait
    }
    catch {
       LogMsg("-------------------ERROR! IIS installation was unsuccessful------------------------")
	   LogMsg("$error")
    }

    LogMsg("Web Deploy for IIS has been installed")
   
}

function Install-Application-With-WebDeploy {

    Param(    
        [parameter(position=0)]
        [string] $PackagePath
    )

    LogMsg("Package Path to install is $PackagePath")

    if ( Test-Path -Path $MSDeployExeDirectory ) {
          LogMsg("Installing the $PackageName using Web Deploy.")
          Set-Location $MSDeployExeDirectory
          .\msdeploy.exe -verb:sync -source:package="$PackagePath" -dest:auto
          LogMsg("The $PackagePath has been installed into IIS")
    } 
    else {        
       LogMsg("The MS Deploy directory is not available.")
       EXIT
    }   

}

function Update-Web-Api-Config {

    Param(    
        [parameter(position=0)]
        [string] $DatabaseUser,
        [parameter(position=1)]
        [string] $DatabasePassword,        
        [parameter(position=2)]
        [string] $DatabaseHost,
        [parameter(position=3)]
        [string] $DatabaseEngine,
        [parameter(position=4)]
        [string] $VersionNumber,
        [parameter(position=5)]
        [string] $ConfigPath
    )
    
       
     If ($DatabaseEngine -eq 'SQLServer') {
       $APIConfigTemplate = "Web.config.API-SQLServer-template"
       LogMsg("DBEngine option is for SQLServer")
     } Else {
       $APIConfigTemplate = "Web.config.API-Postgres-template"
       LogMsg("DBEngine option is for PostgreSQL")
     }

     $ODSConfigTemplatePath = [Io.path]::Combine($DownloadsDirectory,$APIConfigTemplate)

     LogMsg("Downloading the EdFi ODS API Config Template named: $APIConfigTemplate")
     Copy-S3Object -BucketName $S3Bucket -Key configs/$VersionNumber/$APIConfigTemplate -LocalFile $ODSConfigTemplatePath
     

     if ( Test-Path -Path $ODSConfigTemplatePath ) {
     
         $WebApiTextContent = Get-Content -Path "$ODSConfigTemplatePath" -Raw

         ## Depending on the DBEngine to be used, we replace the proper strings
         If ($DBEngine -eq 'SQLServer') {

           LogMsg("Updating ODS API Web.Config file for environment to use SQLServer...")
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Ods"[^\\]*?\/>', "<add name=`"EdFi_Ods`" connectionString=`"Server=$DatabaseHost; User Id=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_{0}; Trusted_Connection=False; Application Name=EdFi.Ods.WebApi;`" providerName=`"System.Data.SqlClient`" />"
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Admin"[^\\]*?\/>', "<add name=`"EdFi_Admin`" connectionString=`"Server=$DatabaseHost; User Id=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_Admin; Trusted_Connection=False; Application Name=EdFi.Ods.WebApi;`" providerName=`"System.Data.SqlClient`" />"
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Security"[^\\]*?\/>', "<add name=`"EdFi_Security`" connectionString=`"Server=$DatabaseHost; User Id=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_Security; Trusted_Connection=False; Persist Security Info=True;  Application Name=EdFi.Ods.WebApi;`" providerName=`"System.Data.SqlClient`" />"
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_master"[^\\]*?\/>', "<add name=`"EdFi_master`" connectionString=`"Server=$DatabaseHost; User Id=$DatabaseUser; Password=$DatabasePassword; Database=master; Trusted_Connection=False; Application Name=EdFi.Ods.WebApi;`" providerName=`"System.Data.SqlClient`" />"

         }  Else {

           LogMsg("Updating ODS API Web.Config file for environment to use PostgreSQL...")
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Ods"[^\\]*?\/>', "<add name=`"EdFi_Ods`" connectionString=`"Host=$DatabaseHost; Port=5432; Username=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_{0}; Application Name=EdFi.Ods.WebApi;`" providerName=`"Npgsql`" />"
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Security"[^\\]*?\/>', "<add name=`"EdFi_Security`" connectionString=`"Host=$DatabaseHost; Port=5432; Username=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_Security; Application Name=EdFi.Ods.WebApi;`" providerName=`"Npgsql`" />"
           $WebApiTextContent = $WebApiTextContent -Replace '<add name="EdFi_Admin"[^\\]*?\/>', "<add name=`"EdFi_Admin`" connectionString=`"Host=$DatabaseHost; Port=5432; Username=$DatabaseUser; Password=$DatabasePassword; Database=EdFi_Admin; Application Name=EdFi.Ods.WebApi;`" providerName=`"Npgsql`" />"
           
        }

        Set-Content "$ODSConfigTemplatePath" $WebApiTextContent

        LogMsg("Copying new Web.config file into place for the ODS/API..")
        Copy-Item $ODSConfigTemplatePath -Destination $ConfigPath -Force
        LogMsg("Updated ODS API Config file for environment.")
    }
    else {
        LogMsg("ERROR!  The $ODSConfigTemplatePath file does not exist.   This most likely means there was an issue using the configuration file template.")
        EXIT 
    }

}


function Update-Swagger-Config {
   
    Param(    
        [parameter(position=0)]
        [string] $ConfigPath
    )
   
    $SwaggerConfigTemplate = "Web.config.Swagger-template"
    $SwaggerConfigTemplatePath = [Io.path]::Combine($DownloadsDirectory,$SwaggerConfigTemplate)

    LogMsg("Downloading the EdFi Swagger Config Template...")
    Copy-S3Object -BucketName $S3Bucket -Key configs/$VersionNumber/$SwaggerConfigTemplate -LocalFile $SwaggerConfigTemplatePath
    LogMsg("Downloading the EdFi Swagger Config Template completed")

    ## Need update Swagger Config
    LogMsg("Updating SwaggerUI Web.Config file for environment...")
    $SwaggerTextContent = Get-Content -Path "$SwaggerConfigTemplatePath" -Raw
    $SwaggerTextContent = $SwaggerTextContent -Replace '<add key="swagger.webApiMetadataUrl"[^\\]*?\/>', "<add key=`"swagger.webApiMetadataUrl`" value=`"https://$DomainName/EdFi.Ods.WebApi/metadata/`"/>"
    $SwaggerTextContent = $SwaggerTextContent -Replace '<add key="swagger.webApiVersionUrl"[^\\]*?\/>', "<add key=`"swagger.webApiVersionUrl`" value=`"https://$DomainName/EdFi.Ods.WebApi/`"/>"
    Set-Content "$SwaggerConfigTemplatePath" $SwaggerTextContent

    LogMsg("Copying new Web.config file into place for the Swagger UI..")
    Copy-Item $SwaggerConfigTemplatePath -Destination $ConfigPath -Force
    LogMsg("Updated SwaggerUI Config file for environment.")
          

}



function Update-Default-Site-Index {
   
   $NewDefaultSiteIndexDoc = "Default.htm"
   $OrgDefaultDocFilePath = "C:\inetpub\wwwroot\iisstart.htm"
   $NewDefaultDocFilePath = "C:\inetpub\wwwroot\Default.htm"

   ### Place the new Default.htm document into the root directory of IIS to force requests to that URL only to the ODS API application
   if ( Test-Path -Path $OrgDefaultDocFilePath ) { 
      LogMsg("Setting up the default document in the IIS Default Web Site root directory...")
      LogMsg("Downloading the default.htm file from S3...")
      Copy-S3Object -BucketName $S3Bucket -Key packages/$NewDefaultSiteIndexDoc -LocalFile $NewDefaultDocFilePath
      LogMsg("Download of default.htm completed.")
    
      LogMsg("Updating default.htm to redirect to $DomainName over SSL...")
      $IndexTextContent = Get-Content -Path "$NewDefaultDocFilePath" -Raw
      $IndexTextContent = $IndexTextContent -Replace 'DOMAINNAME', "$DomainName"
      Set-Content "$NewDefaultDocFilePath" $IndexTextContent
      LogMsg("The default.htm file has been updated to redirect to $DomainName")

      LogMsg("Removing iisstart.htm file from the IIS default website root directory...")
      Remove-Item $OrgDefaultDocFilePath -Force
      LogMsg("The file iisstart.htm has been removed")   

   }

}


### Main Process ###############
if ( -not (Test-Path -Path $LogDirectory) ) {
    New-Item $LogDirectory -ItemType Directory
}

if ( -not (Test-Path -Path $DownloadsDirectory) ) {
       New-Item $DownloadsDirectory -ItemType Directory
}

If ($DBEngine -eq 'SQLServer') {
  LogMsg("DBEngine option is for SQLServer")
} Else {
  LogMsg("DBEngine option is for PostgreSQL")
}


$ODSAPIinstaller = Download-EdFi-Artifacts "EdFi.Ods.WebApi.zip" "$VersionNumber"
LogMsg("ODS Installer Path = $ODSAPIinstaller")

### Install IIS and its required modules to complete the installation, pausing at the end to ensure all is active.
Install-IIS
Install-IISUrlRewriteModule 
Install-IISWebDeployModule
Start-Sleep 5

### Install the ODS API Software 
Install-Application-With-WebDeploy $ODSAPIinstaller

# Update ODS web.config file for database strings and new settings
$WebApiConfigPath = "C:\inetpub\wwwroot\EdFi.Ods.WebApi\Web.config"
Update-Web-Api-Config $DatabaseUser $DatabasePassword $DatabaseHost $DBEngine $VersionNumber $WebApiConfigPath


### If SwaggerUI is to be installed, so this now
If ($InstallSwagger -eq 'yes') {
   
   LogMsg("SwaggerUI option equals yes, and will now be installed...")
   $SwaggerUIinstaller = Download-EdFi-Artifacts "EdFi.Ods.SwaggerUI.zip" "$VersionNumber"
   LogMsg("SwaggerUI Installer Path = $SwaggerUIinstaller")
  
   Install-Application-With-WebDeploy $SwaggerUIinstaller
   
   ## Update Swagger web.config file with ODS/API endpoints
   $SwaggerConfigPath = "C:\inetpub\wwwroot\EdFi.Ods.SwaggerUI\Web.config"
   Update-Swagger-Config $SwaggerConfigPath

} Else {
   LogMsg("SwaggerUI option not equal to yes.  SwaggerUI will not be installed.")
}

## Set up a root doc to redirect to ODS API path
Update-Default-Site-Index

LogMsg("Installation of ODS API Software Suite Completed")
