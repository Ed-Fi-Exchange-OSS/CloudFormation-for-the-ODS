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

### This install script is specifically to handle the installation of the Admin Application for the AWS Quick Deploy option
###  1.) It will install the specific version of the Admin Application based on the ODS/API software version
###  2.) The v1.8.x Admin Application has a much different installation process than the 2.0.x versions, but the script modifies install files as needed.

##### Variables #########
$LogDirectory = "C:\EdFiInstallLogs"
$DownloadsDirectory = "C:\EdFiArtifacts"

$TranscriptFilePath = [Io.path]::Combine($LogDirectory,"ods-api-admin-app-install-transcript.txt")

Start-Transcript -Path "$TranscriptFilePath"

Import-Module PKI

function LogMsg($Msg) {
    Write-Host "$(Get-Date -format 'u') $Msg"
}


###  This function is what defines the Admin Application version that is located in the Ed-Fi MyGet repository. 
####  If versions are added, this funcion may need to be edited if version to download for a specfic ODS/API version of the installer changes.
function Get-Installer-Version-Mapping {
    
    Param(    
        [parameter(position=0)]
        [string] $odsversion    
    )

    ### Use the Admin App Installer script located in MyGet.  This function can provide the mapping based on the ODS/API version being installed
    ### For each new ODS/API version, add an IF block with the ODS version to Admin App Installer version in MyGet
 
    if ( $odsversion -eq "3.4.0") {
        return "3.4.0.686"
    }

    if ( $odsversion -eq "3.4.1") {
        return "3.4.0.686"
    }
      
    ### Default is to use the version of the Admin App Below for v2.0.x and ODS/API v5.x and above
    return "2.0.1"
}


###  This function is what defines the Admin Application filename that is located in the Ed-Fi MyGet repository.  THe name is different depending on the version
###   and the default name returned is for the latest Admin Application installer (v2.0.x).  If versions are added, this funcion may need to be edited if the filename
###   of the installer changes.
function Get-Installer-Filename-Mapping {
    
    Param(    
        [parameter(position=0)]
        [string] $odsversion    
    )

    ### Use the Admin App Installer script located in MyGet.  This function can provide the mapping based on the ODS/API version being installed
    ### For each new ODS/API version, add an IF block with the ODS version to Admin App Installer version in MyGet
 
    if ( $odsversion -eq "3.4.0") {
        return "AdminAppInstaller"
    }

    if ( $odsversion -eq "3.4.1") {
        return "AdminAppInstaller"
    }
      
    ### Default is to use the name of the Admin App Installer Below for v2.0.x and ODS/API v5.x and above
    return "EdFi.Suite3.Installer.AdminApp"
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

    $ExtractedFolder = "$InstallerFilename"
    $ExtractedPath = [Io.path]::Combine($DownloadsDirectory, $ExtractedFolder)

    ## Need to Unzip package
    LogMsg("Extracting Admin App ZIP package to: $ExtractedPath")
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $ExtractedPath
    LogMsg("Admin App Install Package extracted.")

    return $ExtractedPath
}


#### This function is only used when the version of the ODS/API is 3.4.x.  It is for installing the Admin Application v1.8.x
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

#### This function is only used when the version of the ODS/API is v5.0.x or above.  It is for installing the Admin Application Suite 3, v2.0.x
function Modify-Install-Files {

    Param(    
        [parameter(position=0)]
        [string] $Path
    )

    $AdminInstallFile = "install.ps1"
    $InstallFilePath = [Io.path]::Combine($Path, $AdminInstallFile)

    LogMsg("Admin App Installer install.ps1 File Path: $InstallFilePath")
   
    ## Test that extraction is successful and install configuration file exits.  
    ##   If so, need to then populate 'install.ps1' file with values passed to the script for the environment
    if ( Test-Path -Path $InstallFilePath ) {
       LogMsg("Updating Admin App install.ps1 file...")

       $ConfigTextContent = Get-Content -Path "$InstallFilePath" -Raw
       $ConfigTextContent = $ConfigTextContent -Replace "Server = `"[^\\]*?`"", "Server = `"$DatabaseHost`""
       $ConfigTextContent = $ConfigTextContent -Replace "Engine = `"[^\\]*?`"", "Engine = `"$DatabaseEngine`""
       $ConfigTextContent = $ConfigTextContent -Replace 'UseIntegratedSecurity=\$true', "UseIntegratedSecurity = `$false`r`nUsername = `"$DatabaseUser`"`r`nPassword = `"$DatabasePassword`""
       $ConfigTextContent = $ConfigTextContent -Replace "OdsApiUrl = `"[^\\]*?`"", "OdsApiUrl = `"$OdsApiUrl`""

       Set-Content "$InstallFilePath" $ConfigTextContent
 
       LogMsg("Configuration file install.ps1 updated.")
    }
    else {
       LogMsg("ERROR!  Could not find the install.ps1 file to edit for the Admin Application.  This indicates a problem with the install of the software and requires support.")
       LogMsg("$error")
       $error.Clear()
    }

}

#### This function is only used when the version of the ODS/API is v5.0.x or above.  It is for installing the Admin Application Suite 3, v2.0.x
#### We need to remove the call in the module that attempts to update the database as the DB is already setup from the ODS/API Binary installation.
function Modify-Suite3-Powershell-Module {
    
    Param(    
        [parameter(position=0)]
        [string] $Path
    )
  
    $AdminInstallModuleFile = "Install-EdFiOdsAdminApp.psm1"
    $InstallModulePath = [Io.path]::Combine($Path, $AdminInstallModuleFile)

    LogMsg("Admin App Installer Install Module File Path: $InstallModulePath")

    if ( Test-Path -Path $InstallModulePath ) {
       LogMsg("Updating Admin App Install-EdFiOdsAdminApp.psm1 file to prevent DBUpdate call from occurring with Suite 3...")

       ### $result += Invoke-DbUpScripts -Config $Config
       $ConfigTextContent = Get-Content -Path "$InstallModulePath" -Raw
       $ConfigTextContent = $ConfigTextContent -Replace '\$result \+\= Invoke-DbUpScripts -Config', "## Removed DbUpScripts call for AWS Quick Deploy Install"

       Set-Content "$InstallModulePath" $ConfigTextContent
 
       LogMsg("Powershell file Install-EdFiOdsAdminApp.psm1 updated.")
    }
    else {
       LogMsg("ERROR!  Could not find the Install-EdFiOdsAdminApp.psm1 file to edit for the Admin Application.  This indicates a problem with the install of the software and requires support.")
       LogMsg("$error")
       $error.Clear()
    }

}


function Install-Admin-App {

    Param(    
        [parameter(position=0)]
        [string] $Path,
	    [parameter(position=1)]
        [string] $InstallerName
    )

    
    if ($InstallerName -eq 'AdminAppInstaller') {
        ## Set the install script to include the -DisableMigations option to avoid any database actions as the solution already has placed the databases into the RDS.
        $AdminAppInstallScript = "tools\install.ps1 -DisableMigrations"
    } Else {
	$AdminAppInstallScript = "install.ps1"	
    }

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

    Param(    
	[parameter(position=0)]
        [string] $InstallerName
    )

    $AdminAppWebConfigFilePath = "C:\inetpub\Ed-Fi\AdminApp\Web.config"
       
    try {
        LogMsg("Updating AdminApp Web.Config file...")
        $AdminAppTextContent = Get-Content -Path "$AdminAppWebConfigFilePath" -Raw
        $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="ProductionApiUrl"[^\\]*?\/>', "<add key=`"ProductionApiUrl`" value=`"$OdsApiUrl`" />"
        $AdminAppTextContent = $AdminAppTextContent -Replace '<appSettings file="[^\\]*?>', "<appSettings>"
        
        LogMsg("Checking for v1.8.x Admin App Installer to see if we need to update the ASP.NET key value...if so, updating next...")
	LogMsg("InstallerName = $InstallerName")

        ## This will only execute if the version of the Admin App is for use with ODS/API v3.4.x
        If ($InstallerName -eq 'AdminAppInstaller') {
            LogMsg("Version 1.8.x Admin App configuration detected....Updating ASP.NET identity value to true...")
            $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="AspNetIdentityEnabled"[^\\]*?>', "<add key=`"AspNetIdentityEnabled`" value=`"true`" />"
        }
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

#### This function is only used when the version of the ODS/API is v3.4.x or.  It is needed to set the proper authentication process for the Admin Application v1.8.x
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

### Due to the different way the Admin Application versions the installer, we need to get the proper mapping based on the ODS/API Version.
$InstallerVersion = Get-Installer-Version-Mapping "$VersionNumber"
$InstallerFilename = Get-Installer-Filename-Mapping "$VersionNumber"

LogMsg("Installer Version = $InstallerVersion")
LogMsg("Installer Filename = $InstallerFilename")

$AdminAppInstallerPackage = Download-EdFi-AdminApp "$InstallerFilename" "$InstallerVersion"
LogMsg("AdminApp Installer Package Path = $AdminAppInstallerPackage")

#### Begin Install Process
Install-IIS

$AdminAppUnzipPath = Extract-Admin-App-Package $AdminAppInstallerPackage

### Based on which installer us being used, modify the proper files to be used with AWS and the installation process
if ($InstallerFilename -eq 'AdminAppInstaller') {
    Create-JSON-Config-File $AdminAppUnzipPath
} Else {
    Modify-Install-Files $AdminAppUnzipPath 
    Modify-Suite3-Powershell-Module $AdminAppUnzipPath
}
	
Install-Admin-App $AdminAppUnzipPath $InstallerFilename

Update-Admin-App-Config $InstallerFilename

Adjust-IIS-For-Environment-Type

#### If we are using the Admin Application v1.8.x for ODS/API v3.4.x, we need to do an additional configuration update to the Admin Application
if ($InstallerFilename -eq 'AdminAppInstaller') {
    Enable-ASP-Net-Identity-In-Site
}

LogMsg("EdFi Admin App Install and Configuration Completed.")

