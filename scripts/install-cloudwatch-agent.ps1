param(
    [Parameter(Mandatory=$false)]
    [string]$EnvLabel,

    [Parameter(Mandatory=$false)]
    [string]$S3Bucket
)

try {
    $ErrorActionPreference = "Stop"
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append

    #### Install CW Logs Agent
    $CWAgentInstallerLocation="https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi"
    $CWAgentInstallerPath = "C:\amazon-cloudwatch-agent.msi"
    $CWAgentConfigPath = "C:\ProgramData\Amazon\AmazonCloudWatchAgent\Configs\config.json"

    $start_time = Get-Date
    (New-Object System.Net.WebClient).DownloadFile($CWAgentInstallerLocation, $CWAgentInstallerPath)
    Write-Output "Time taken to download file: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    Write-Output "Installing the CloudWatch Agent for Windows"
    Start-Process "msiexec.exe" -ArgumentList "/i $CWAgentInstallerPath /quiet" -Wait
    Write-Output "CloudWatch Agent has been installed"
    Start-Sleep 5

    ### Download the Ed-Fi AWS CloudWatch Configuration File from S3 and put into the proper location 
    Write-Output "Downloading the Ed-Fi CloudWatch Agent configuration file from S3"

    Copy-S3Object -BucketName $S3Bucket -Key packages/cloudwatch_config.json -LocalFile $CWAgentConfigPath
    Write-Output "CloudWatch Agent Configuration file has been downloaded" 
    Start-Sleep 2

    ### Replace the ENVLABEL text in the generic configuration file with the $EnvLabel parameter value
    Write-Output "Creating the configuration file for CloudWatch..."
    if ( Test-Path -Path $CWAgentConfigPath ) {
       $TextContent = Get-Content -Path "$CWAgentConfigPath" -Raw
       $TextContent = $TextContent -Replace 'ENVLABEL', "$EnvLabel"
       Set-Content "$CWAgentConfigPath" $TextContent  
       Write-Output "Configuration file created and placed into proper location"
    }
    else {
       Write-Output "ERROR!  The $CWAgentConfigPath file does not exist.   This most likely means there was an issue downloading from the default Ed-Fi S3 bucket"
       EXIT 
    }  
    
    ## RestartCloudWatch Agent Service to have new config take affect
    Write-Output "Restarting the Amazon CloudWatch Agent to load new configuration file"
    Restart-Service -Name AmazonCloudWatchAgent -Force
    Write-Output "Restart complete."
    Write-Output "CloudWatch Agent for Windows installation completed."
   
    
}
catch {
    Write-Output "ERROR!  CloudWatch Agent installation was unsuccessful"
	Write-Outout "$error"
	$error.Clear()
}
