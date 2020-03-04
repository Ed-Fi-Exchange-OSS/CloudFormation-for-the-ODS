Param([string]$DatabaseHost, [string]$DatabaseUser, [string]$DatabasePassword, [string]$DomainName, [string]$InstallSwagger, [string]$AdminAppUserName, [string]$AdminAppPassword, [string]$InstallNonProd, [string]$S3Bucket)


$LogFile = "EdFi-Admin-App-Install-Process.txt"
$TranscriptFile = "ods-admin-app-transcript-log.txt"
$AdminAppExeLog = "admin-app-command-line-install.log"
$AdminAppMSILog = "admin-app-msi-installer.log"
$LogDirectory = "C:\EdFiInstallLogs"

if ( -not (Test-Path -Path $LogDirectory) ) {
    New-Item $LogDirectory -ItemType Directory
}

$TranscriptFilePath = [Io.path]::Combine($LogDirectory,$TranscriptFile)
$LogFilePath = [Io.path]::Combine($LogDirectory,$LogFile)
$AdminAppMSILogFilePath = [Io.path]::Combine($LogDirectory,$AdminAppMSILog)
$AdminAppEXELogFilePath = [Io.path]::Combine($LogDirectory,$AdminAppExeLog)


$DownloadsDirectory = 'C:\EdFiArtifacts'
$WebDeployInstallPackage = 'WebDeploy_amd64_en-US.msi'
$UrlRewriteInstallPackage = 'rewrite_amd64_en-US.msi'
$AppName = 'Ed-Fi'
$AdminAppInstallRootDir = 'C:\EdFi'
$AdminAppConfigDir = "EdFi.Ods.AdminApp.Web"
$AppNamePackage = 'Ed-Fi_ODS_AdminApp_1.6_3.2.exe'
$MSDeployExeDirectory = "C:\Program Files\IIS\Microsoft Web Deploy V3"
$IISRootFolderName = "C:\inetpub\wwwroot"
$WebConfigFileName = 'Web.config'
$IISAppConfigDirectory = "C:\Windows\System32\inetsrv\config"
$IISAppConfigFile = "applicationHost.config"
$AdminAppPort = "444"
$AdminSecretJsonFile = "secret.json"

Start-Transcript -Path "$TranscriptFilePath"

function LogMsg($Msg)
{
    Write-Host "$(Get-Date -format 'u') $Msg"
    Add-Content $LogFilePath "$(Get-Date -format 'u') $Msg `n"
}


If ($InstallNonProd -eq 'yes') {
   $OdsApiUrl = "http://" + $DomainName + "/EdFi.Ods.WebApi"
   $SwaggerUrl = "http://" + $DomainName + "/EdFi.Ods.SwaggerUI"
   LogMsg("InstallNonProd option equals yes, and we adjust the Admin App IIS binding for port 444.")
} Else {
   $OdsApiUrl = "https://" + $DomainName + "/EdFi.Ods.WebApi"
   $SwaggerUrl = "https://" + $DomainName + "/EdFi.Ods.SwaggerUI"
   LogMsg("InstallNonProd option equals no, so we will adjust the Admin App IIS binding for port 443.")
}


$IISAppConfigFilePath = [Io.path]::Combine($IISAppConfigDirectory,$IISAppConfigFile)
$AdminAppPackagePath = [Io.path]::Combine($DownloadsDirectory,$AppNamePackage)
$WebDeployPackagePath = [Io.path]::Combine($DownloadsDirectory,$WebDeployInstallPackage)
$URLRewritePackagePath = [Io.path]::Combine($DownloadsDirectory,$UrlRewriteInstallPackage)
$AdminAppWebConfigFilePath = [Io.path]::Combine($AppName,$WebConfigFileName)
$AdminAppExePath = [Io.path]::Combine($DownloadsDirectory,$AppNamePackage)
$AdminAppConfigPath = [Io.path]::Combine($AdminAppInstallRootDir,$AdminAppConfigDir)
$AdminAppSecretFilePath = [Io.path]::Combine($AdminAppConfigPath,$AdminAppSecretJsonFile)


function Get-RandomString {
    Param(
       [int] $length = 20
    )

    return ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | Sort-Object { Get-Random })[0..$length] -join ""
}



LogMsg("Starting the setup of the ODS Admin Application Server...")

If ($InstallSwagger -eq 'yes') {
   LogMsg("SwaggerUI option equals yes, and will configure the Admin App to use Swagger at the Domain Name URL...")
} Else {
   LogMsg("SwaggerUI option not equal to yes.  Admin App will not be configured for SwaggerUI")
}

try
{
   ### Need to download EdFi Artficats from the publicly accessible S3 bucket for the Quick Deploy
   LogMsg("Downloading the EdFi Admin App Package...")
   Copy-S3Object -BucketName $S3Bucket -Key packages/$AppNamePackage -LocalFile $AdminAppPackagePath
   LogMsg("Downloading the EdFi Admin App Package completed")
}
catch
{
   LogMsg("ERROR! Unable to download the required files Admin Application package from S3.  Please see the error below.")
   LogMsg("$error") 
   $error.Clear()	
   EXIT
}


#### Begin Install Process
LogMsg("Installing the Servermanager and the PKI module...")
Import-Module Servermanager
Import-Module PKI

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
Start-Sleep -s 5


If ($InstallNonProd -eq 'no') {
   try
     {
        LogMsg("Downloading the WebDeploy IIS Package...")
        Copy-S3Object -BucketName $S3Bucket -Key packages/$WebDeployInstallPackage -LocalFile $WebDeployPackagePath
        LogMsg("Downloading the WebDeploy Package complete")

        LogMsg("Downloading the URL Rewrite Module Package...")
        Copy-S3Object -BucketName $S3Bucket -Key packages/$UrlRewriteInstallPackage -LocalFile $URLRewritePackagePath
        LogMsg("Downloading the URL Rewrite Package complete")

        LogMsg("Installing the URL Rewrite Module for IIS")
        Start-Process "msiexec.exe" -ArgumentList "/i $DownloadsDirectory\$UrlRewriteInstallPackage /quiet" -Wait
        LogMsg("URL Rewrite Module for IIS has been installed")
        Start-Sleep -s 10

        LogMsg("Installing the Web Deploy package for IIS...")
        Start-Process "msiexec.exe" -ArgumentList "/i $DownloadsDirectory\$WebDeployInstallPackage /quiet" -Wait
        LogMsg("Web Deploy for IIS has been installed")
        Start-Sleep -s 10
     }
   catch
     {
        LogMsg("ERROR! Unable to download required IIS packages from S3.  Please see error below:")
        LogMsg("$error")
        $error.Clear()	
        EXIT 
     }

} Else {
   LogMsg("InstallNonProd option equals yes, so we do not need to install the WebDeploy or URL Rewite packages.")
}


#### Create a Self-Signed SSL certificate
$plainPassword = Get-RandomString
LogMsg("$plainPassword")
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$certFile = "$PSScriptRoot\Ed-Fi-ODS-SelfSignedCertificate.pfx"

$certParams = @{
CertStoreLocation = 'Cert:\LocalMachine\My'
Subject = $env:computername
DnsName = $env:computername
KeyExportPolicy = 'Exportable'
KeyAlgorithm = 'RSA'
KeyLength = 2048
FriendlyName = "Ed-Fi-ODS"
}

$cert = (dir $certParams.CertStoreLocation | ? { $_.subject -like "*$($certParams.Subject)*" -and $_.FriendlyName -like $($certParams.FriendlyName) })

if(!$cert) { 
    #Remove Root certificate as we need to create a new one
    $rootcert = (dir cert:\LocalMachine\Root\ | ? { $_.subject -like "*$($certParams.Subject)*" -and $_.FriendlyName -like $($certParams.FriendlyName) })
    if($rootcert) {
      $rootcert | Remove-Item
    }

    $cert = (New-SelfSignedCertificate @certParams)
}

## Export to file
$exportCertParams = @{
Cert = "cert:\LocalMachine\My\$($cert.Thumbprint)"
FilePath = $certFile
Password = $password
}
$rootcert = (dir cert:\LocalMachine\Root\ | ? { $_.subject -like "*$($certParams.Subject)*" -and $_.FriendlyName -like $($certParams.FriendlyName) })

if(!$rootcert){
   Export-PfxCertificate @exportCertParams
   Import-PfxCertificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath $certFile -Password $password
}

LogMsg("SSL Certificate Created.  Thumbprint below:")
LogMsg($cert.Thumbprint)

$SSLThumbprint = $cert.Thumbprint

LogMsg($SSLThumbprint)

Start-Sleep 5

try
{
    LogMsg("Installing the ODS Admin App...")
    Start-Process -FilePath $AdminAppExePath -ArgumentList "/exenoui /exelog $AdminAppEXELogFilePath /l*vx $AdminAppMSILogFilePath APPDIR=`"$AdminAppInstallRootDir`" USER_NAME=$AdminAppUserName USER_PASSWORD=$AdminAppPassword DOMAIN_NAME=`".\`" SERVER_PROP=$DatabaseHost ODS_DATABASE_NAME=EdFi_Ods ODS_API_URL=`"$OdsApiUrl`" ODS_CERTIFICATE_THUMB=`"$SSLThumbprint`" /qn"
}
catch
{
    LogMsg("ERROR! Installation of ODS Admin Application Failed!  See error below:")
    LogMsg("$error")
    $error.Clear()	
    EXIT 
}

Start-Sleep 45

LogMsg("Install Admin App Completed to C:\EdFi...moving to configuration")


if ( Test-Path -Path $AdminAppSecretFilePath )
{
    LogMsg("Updating Admin App secret.json file...")
    $AdminAppSecretJson = "$AdminAppConfigPath\secret.json"
    $SecretJsonContent = "{`r`n"
    $SecretJsonContent = $SecretJsonContent + "  `"AdminCredentials`": {`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"Password`": `"$DatabasePassword`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"UserName`": `"$DatabaseUser`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"UseIntegratedSecurity`":  `"false`"`r`n"
    $SecretJsonContent = $SecretJsonContent + "   },`r`n"
    $SecretJsonContent = $SecretJsonContent + "   `"StagingApiCredentials`": {`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"Password`": `"`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"UserName`": `"`"`r`n"
    $SecretJsonContent = $SecretJsonContent + "   },`r`n"
    $SecretJsonContent = $SecretJsonContent + "   `"HostName`": `"$DatabaseHost`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "   `"ProductionApiCredentials`": {`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"Password`": `"`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"UserName`": `"EdFiOdsProductionApi`"`r`n"
    $SecretJsonContent = $SecretJsonContent + "   },`r`n"
    $SecretJsonContent = $SecretJsonContent + "   `"AdminAppCredentials`": {`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"Password`": `"`",`r`n"
    $SecretJsonContent = $SecretJsonContent + "     `"UserName`": `"EdFiOdsAdminApp`"`r`n"
    $SecretJsonContent = $SecretJsonContent + "   }`r`n"
    $SecretJsonContent = $SecretJsonContent + "}`r`n"
    Set-Content "$AdminAppSecretJson" $SecretJsonContent 
    LogMsg("Configuration file secret.json updated.")
}
else
{
    LogMsg("ERROR!  Could not find the secret.json file to edit for the Admin Application.  This indicates a problem with the install of the software and requires support.")
    EXIT
}


Start-Sleep 5

LogMsg("Updating AdminApp Web.Config file...")
$AdminAppWebConfig = "$AdminAppConfigPath\Web.config"
$AdminAppTextContent = Get-Content -Path "$AdminAppWebConfig"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add name="EdFi_Admin".*\/>', "<add name=`"EdFi_Admin`" connectionString=`"Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Initial Catalog=EdFi_Admin;Integrated Security=False`" providerName=`"System.Data.SqlClient`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add name="EdFi_Security".*\/>', "<add name=`"EdFi_Security`" connectionString=`"Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Initial Catalog=EdFi_Security;Integrated Security=False`" providerName=`"System.Data.SqlClient`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add name="EdFi_Ods_Production".*\/>', "<add name=`"EdFi_Ods_Production`" connectionString=`"Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Initial Catalog=EdFi_Ods;Integrated Security=False`" providerName=`"System.Data.SqlClient`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add name="EdFi_Ods_Staging".*\/>', "<add name=`"EdFi_Ods_Staging`" connectionString=`"Data Source=$DatabaseHost;User Id=$DatabaseUser;Password=$DatabasePassword;Initial Catalog=EdFi_Ods;Integrated Security=False`" providerName=`"System.Data.SqlClient`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add key="StagingApiUrl"[^\\]*?\/>', "<add key=`"StagingApiUrl`" value=`"$OdsApiUrl`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<add key="ProductionApiUrl"[^\\]*?\/>', "<add key=`"ProductionApiUrl`" value=`"$OdsApiUrl`" />"
$AdminAppTextContent = $AdminAppTextContent -Replace '<appSettings file="[^\\]*?>', "<appSettings>"

### Configure SwaggerUI value if given the proper command line parameter
If ($InstallSwagger -eq 'yes') {
   $AdminAppTextContent = $AdminAppTextContent -Replace '<add key="SwaggerUrl"[^\\]*?\/>', "<add key=`"SwaggerUrl`" value=`"$SwaggerUrl`" />"
}

Set-Content "$AdminAppWebConfig" $AdminAppTextContent 
LogMsg("Configuration file web.config is updated...")

Start-Sleep 5

## For a Prod Admin App server we need to set it up to port 443 as it is on its own server and turn of the default web site
If ($InstallNonProd -eq 'no') {
   
  $AdminAppPort = "443"
   
  ## Turn off Default Web Site in IIS if on our own server; may need to remove this after security audit with Remove-Site
  Stop-WebSite -Name 'Default Web Site'
  LogMsg("Stopped the IIS Default Web Site...")

  ### Give Time for Site to stop
  Start-Sleep 10
  

} Else {
  
  ## Add a firewall rule to Windows Firewall to allow Admin Application to be accessed on a non-standard port
  LogMsg("Adding a Windows Firewall Rule to allow Admin Application on TCP 444..")
  New-NetFireWallRule -DisplayName 'EdFi ODS API Admin Application' -Direction 'Inbound' -Action 'Allow' -Protocol 'TCP' -LocalPort @('444')
}

LogMsg("Admin App Port will be $AdminAppPort") 

try
{
    ## Change Binding on the Admin App Website in IIS to map to the proper TCP Port
    Get-WebBinding -Name 'Ed-Fi' -Port 444 | Remove-WebBinding
    LogMsg("Removed existing Admin App IIS binding on port 444...")
    Start-Sleep 5

    New-WebBinding -Name 'Ed-Fi' -IPAddress "*" -Port $AdminAppPort -Protocol "https"
    LogMsg("Created new IIS binding to port $AdminAppPort for the Ed-Fi Admin App")
    Start-Sleep 5

    LogMsg("Binding the new SSL certificate to the Ed-Fi IIS Site on port $AdminAppPort")
    $httpsBinding=Get-WebBinding -Name 'Ed-Fi' -Port $AdminAppPort
    $httpsBinding.AddSslCertificate("$SSLThumbprint", "my")
}
catch
{
     LogMsg("ERROR! Unable to set IIS to use the self-signed SSL certificate.  Please see error below:")
     LogMsg("$error")
     $error.Clear()	
     EXIT 
}

LogMsg("EdFi Admin App Install and Configuration Completed.")

