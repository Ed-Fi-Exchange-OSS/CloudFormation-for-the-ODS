Param([string]$DatabaseHost, 
      [string]$DatabaseUser, 
      [string]$DatabasePassword,
      [string]$DBEngine,
      [string]$DomainName, 
      [string]$InstallSwagger,
      [string]$InstallNonProd,
      [string]$VersionNumber
)

$ErrorActionPreference = "Stop"

##### Variables #########
$LogDirectory = "C:\EdFiInstallLogs"
$DownloadsDirectory = "C:\EdFiArtifacts"

$TranscriptFilePath = [Io.path]::Combine($LogDirectory,"ods-api-admin-app-install-transcript.txt")

Start-Transcript -Path "$TranscriptFilePath"

Import-Module PKI

function LogMsg($Msg) {
    Write-Host "$(Get-Date -format 'u') $Msg"
}

function Get-Installer-Version-Mapping {
    
    Param(    
        [parameter(position=0)]
        [string] $odsversion    
    )

    ### Use the Admin App Installer script located in MyGet.  This function can provide the mapping based on the ODS/API version being installed
    ### For each new ODS/API version, add an IF block with the ODS version to Admin App Installer version in MyGet
 
    if ( $odsversion -eq "3.4.0") {
        return "3.4.0.584"
    }

    
}

function Download-Edfi-AdminApp {
   
    Param(    
        [parameter(position=0)]
        [string] $filename,
        [parameter(position=1)]
        [string] $version  
    )
 
    ## Build the Admin App Installer NuGet Package to be a ZIP extension to allow for easier extractions in the AWS solution.
    $packageName =  "$filename.$version.zip"

    $OutputFile = (Join-Path $DownloadsDirectory $packageName)    

    $packageSource = "https://www.myget.org/F/ed-fi/api/v2/package/$filename/$version"

    LogMsg("Downloading file from $packageSource to $OutputFile")
  
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

function Extract-Admin-App-Package {

    Param(    
        [parameter(position=0)]
        [string] $PackagePath
    )

    $ExtractedFolder = "AdminAppInstaller"
    $ExtractedPath = [Io.path]::Combine($DownloadsDirectory, $ExtractedFolder)

    ## Need to Unzip package
    LogMsg("Extracting Admin App ZIP package to: $ExtractedPath")
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $ExtractedPath
    LogMsg("Admin App Install Package extracted.")

    return $ExtractedPath
}

function Create-JSON-Config-File {

    Param(    
        [parameter(position=0)]
        [string] $Path
    )

    $AdminConfigJsonFile = "tools\install-config.json"
    $InstallConfigPath = [Io.path]::Combine($Path, $AdminConfigJsonFile)

    LogMsg("Admin App Installer Configuration File Path: $InstallConfigPath")

    ## Test that extraction is successful and install configuration file exits.  
    ##   If so, need to then populate 'install-config.json' file with values passed to the script for the environment
    if ( Test-Path -Path $InstallConfigPath ) {
       LogMsg("Updating Admin App install-config.json file...")

       $ConfigTextContent = Get-Content -Path "$InstallConfigPath" -Raw
       $ConfigTextContent = $ConfigTextContent -Replace '"apiUrl":[^\\]*?,', "`"apiUrl`": `"$OdsApiUrl`","
       $ConfigTextContent = $ConfigTextContent -Replace '"databaseUser" :[^\\]*?,', "`"databaseUser`" : `"$DatabaseUser`","
       $ConfigTextContent = $ConfigTextContent -Replace '"databasePassword" :[^\\]*?,', "`"databasePassword`" : `"$DatabasePassword`","
       $ConfigTextContent = $ConfigTextContent -Replace '"databaseServer" :[^\\]*?,', "`"databaseServer`" : `"$DatabaseHost`","
       $ConfigTextContent = $ConfigTextContent -Replace '"useIntegratedSecurity" : true', "`"useIntegratedSecurity`" : false"
       $ConfigTextContent = $ConfigTextContent -Replace '"engine" : [^\\]*?,', "`"engine`" : `"$DatabaseEngine`","
       $ConfigTextContent = $ConfigTextContent -Replace '"databasePort" :[^\\]*?,', "`"databasePort`" : `"$DatabasePort`","

       Set-Content "$InstallConfigPath" $ConfigTextContent
   
       LogMsg("Configuration file install-config.json updated.")
    }
    else {
       LogMsg("ERROR!  Could not find the install-config.json file to edit for the Admin Application.  This indicates a problem with the install of the software and requires support.")
       LogMsg("$error")
       $error.Clear()
    }


}

function Install-Admin-App {

    Param(    
        [parameter(position=0)]
        [string] $Path
    )

    ## Set the install script to include the -DisableMigations option to avoid any database actions as the solution already has placed the databases into the RDS.
    $AdminAppInstallScript = "tools\install.ps1 -DisableMigrations"
    $AdminAppInstallScriptPath = [Io.path]::Combine($Path, $AdminAppInstallScript)
    
    LogMsg("Admin App Installer Script File Path: $AdminAppInstallScriptPath")


    ## Execute 'install.ps1' script and let it take care of Admin App installation
    try {
        LogMsg("Installing Admin Application via the $AdminAppInstallScript script command...")
        Invoke-Expression $AdminAppInstallScriptPath
        LogMsg("Admin Application installation completed.")
    }
    catch {
        LogMsg("ERROR!  $AdminAppInstallScript script failed with an exit code.  Please see install logs for further details.")
        LogMsg("$error")
    }

}

function Update-Admin-App-Config {

    $AdminAppWebConfigFilePath = "C:\inetpub\Ed-Fi\AdminApp\Web.config"
       
    try {
        LogMsg("Updating AdminApp Web.Config file...")
        $AdminAppTextContent = Get-Content -Path "$AdminAppWebConfigFilePath" -Raw
        $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="ProductionApiUrl"[^\\]*?\/>', "<add key=`"ProductionApiUrl`" value=`"$OdsApiUrl`" />"
        $AdminAppTextContent = $AdminAppTextContent -Replace '<appSettings file="[^\\]*?>', "<appSettings>"
        $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="AspNetIdentityEnabled"[^\\]*?>', "<add key=`"AspNetIdentityEnabled`" value=`"true`" />"
  
        ### Configure SwaggerUI value if given the proper command line parameter
        If ($InstallSwagger -eq 'yes') {
            $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="SwaggerUrl"[^\\]*?\/>', "<add key=`"SwaggerUrl`" value=`"$SwaggerUrl`" />"
        }

        Set-Content "$AdminAppWebConfigFilePath" $AdminAppTextContent 
        LogMsg("Configuration file web.config is updated for AWS...")
    }
    catch {
        LogMsg("ERROR!  Unable to access and edit the Admin App web.config file to update.  Please see install logs for further details.")
        LogMsg("$error")
        $error.Clear()
    }

}

function Adjust-IIS-For-Environment-Type {


    ## For NonProd systems, adjust the IIS binding and system to use TCP/444  
    ## For a Prod Admin App server we need to set it up to port 443 as it is on its own server and turn off the default web site
    If ($InstallNonProd -eq 'no') {
          $AdminAppPort = "443"
          ## Turn off Default Web Site in IIS if on same server as ODS API in AWS to avoid port conflicts
          Stop-WebSite -Name 'Default Web Site'
          LogMsg("Stopped the IIS Default Web Site...")

          ### Give Time for Site to stop
          Start-Sleep 1
  
    } Else {
         ## Add a firewall rule to Windows Firewall to allow Admin Application to be accessed on a non-standard port
         $AdminAppPort = "444"
         LogMsg("Adding a Windows Firewall Rule to allow Admin Application on TCP 444..")
         New-NetFireWallRule -DisplayName 'EdFi ODS API Admin Application' -Direction 'Inbound' -Action 'Allow' -Protocol 'TCP' -LocalPort @('444')
    }


    ## Regardless if its Prod or Non-Prod we need to properly configure the IIS Site Binding on the Port to *not* include the local machine name
    try {
       
       ## Get the Thumbprint of the self-signed certificate just created by install.ps1 for the Admin App
       $cert = Get-ChildItem -path Cert:\LocalMachine\My -Recurse | where {$_.FriendlyName -like "Ed-Fi-ODS"}
       $edficertificate = $cert.Thumbprint
       LogMsg("SSL Certificate of Admin App self-signed cert: $edficertificate")

       ## Change Binding on the Admin App Website in IIS to map to the proper TCP Port
       Get-WebBinding -Name 'Ed-Fi' -Port 443 | Remove-WebBinding
       LogMsg("Removed existing Admin App IIS binding on port 443...")
       Start-Sleep 2

       New-WebBinding -Name 'Ed-Fi' -IPAddress "*" -Port $AdminAppPort -Protocol "https"
       LogMsg("Created new IIS binding to port $AdminAppPort for the Ed-Fi Admin App")
       Start-Sleep 2

       LogMsg("Binding the Ed-Fi Admin App SSL certificate to the Ed-Fi IIS Site on port $AdminAppPort")
       $httpsBinding=Get-WebBinding -Name 'Ed-Fi' -Port $AdminAppPort
       $httpsBinding.AddSslCertificate("$edficertificate", "my")
       LogMsg("Admin App SSL Certificate binded to Ed-Fi Admin App site...")
    }
    catch {
       LogMsg("ERROR! Unable to set IIS to use the self-signed SSL certificate.  Please see error below:")
       LogMsg("$error")
    }

}

function Enable-ASP-Net-Identity-In-Site {

     ## Enable Anoymous Authentication and disable Windows Authentication on the Admin App site to allow ASP.NET logins
     ### Import the Web-Administration module to ensure we can execute the command 
     Import-Module WebAdministration
       
     LogMsg("Enabling Anonymous Authentication and disaling Windows Authentication on the Admin App site to use ASP.NET logins..")
     $PSPath="IIS:\"
     $LocationPath="Ed-Fi/AdminApp"
     Set-WebConfigurationProperty -Filter /system.WebServer/security/authentication/AnonymousAuthentication -Name enabled -Value true -Location $LocationPath -PSPath $PSPath
     Set-WebConfigurationProperty -Filter /system.WebServer/security/authentication/WindowsAuthentication -Name enabled -Value false -Location $LocationPath -PSPath $PSPath
     LogMsg("Authentication settings adjusted.")

}

#### Main Process #################################################

LogMsg("Starting the setup of the ODS Admin Application...")

if ( -not (Test-Path -Path $LogDirectory) ) {
    New-Item $LogDirectory -ItemType Directory
}

if ( -not (Test-Path -Path $DownloadsDirectory) ) {
       New-Item $DownloadsDirectory -ItemType Directory
}

If ($InstallNonProd -eq 'yes') {
   $OdsApiUrl = "http://" + $DomainName + "/EdFi.Ods.WebApi"
   $SwaggerUrl = "http://" + $DomainName + "/EdFi.Ods.SwaggerUI"
   LogMsg("InstallNonProd option equals yes, so we use the localhost for the ODS/API, and we will adjust the Admin App IIS binding for port 444.")
} Else {
   $OdsApiUrl = "https://" + $DomainName + "/EdFi.Ods.WebApi"
   $SwaggerUrl = "https://" + $DomainName + "/EdFi.Ods.SwaggerUI"
   LogMsg("InstallNonProd option equals no, so we will adjust the Admin App IIS binding for port 443.")
}


If ($InstallSwagger -eq 'yes') {
   LogMsg("SwaggerUI option equals yes, and will configure the Admin App to use Swagger at the Domain Name URL...")
} Else {
   LogMsg("SwaggerUI option not equal to yes.  Admin App will not be configured for SwaggerUI")
}


If ($DBEngine -eq 'SQLServer') {
   LogMsg("DBEngine option is for SQL Server.  Will be changing database engine and port in configuration installation file")
   $DatabaseEngine="SQLServer"
   $DatabasePort="1433"
} Else {
   LogMsg("DBEgine option is for PostgreSQL.  Leaving default databse engine configurations for use with PostgreSQL")
   $DatabaseEngine = "PostgreSQL"
   $DatabasePort = "5432"
}

LogMsg("DB Engine value is $DatabaseEngine")
LogMsg("DB Port value is $DatabasePort")

### Due to the different way the Admin Application versions the installer, we need to get the proper mapping based on the ODS API Version.
$InstallerVersion = Get-Installer-Version-Mapping "$VersionNumber"

$AdminAppInstallerPackage = Download-EdFi-AdminApp "AdminAppInstaller" "$InstallerVersion"
LogMsg("AdminApp Installer Package Path = $AdminAppInstallerPackage")

#### Begin Install Process
Install-IIS

$AdminAppUnzipPath = Extract-Admin-App-Package $AdminAppInstallerPackage

### Edit the Admin App Installer configuraiton file to match requested setup options
Create-JSON-Config-File $AdminAppUnzipPath

Install-Admin-App $AdminAppUnzipPath

Update-Admin-App-Config 

Adjust-IIS-For-Environment-Type

Enable-ASP-Net-Identity-In-Site


LogMsg("EdFi Admin App Install and Configuration Completed.")

