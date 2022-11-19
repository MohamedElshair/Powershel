﻿Clear-Host ; cd\
$Project_Name             = $Project_Name
$Net_BIOS_Name            = 'Itoutbreak'
$Domain_Name              = "$Net_BIOS_Name" + "." + "net"
$ComputerName             = "SCCM"
$VM_Name                  = "$Project_Name" + "-" + "$ComputerName"
$LocalUserNameSRV         = 'administrator'
$LocalUserNameCLT         = '.\admin'
$DomainUserName           = "$Net_BIOS_Name\$LocalUserNameSRV"
$Password                 = ConvertTo-SecureString -String 'P@$$w0rd' -AsPlainText -Force
$LocalCredentialServer    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LocalUserNameSRV,$Password
$LocalCredentialClient    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LocalUserNameCLT,$Password
$DomainCredential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUserName,$Password

$DatabasePath             = 'c:\windows\NTDS'
$LogPath                  = 'c:\windows\NTDS'
$SysvolPath               = 'c:\windows\SYSVOL'
$StartRange               = '10.0.0.100' 
$EndRange                 = '10.0.0.200'
$DNS_Server               = '10.0.0.10'
hostname ; whoami


### Logon to local machine "Server" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialServer 
Enter-PSSession -VMName "WSUS" -Credential $LocalCredentialServer 
### Logon to local machine "Client" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialClient
### Logon to domain joined machine ###
Enter-PSSession -VMName "$VM_Name" -Credential $DomainCredential

cd\ ; Clear ; hostname ; whoami

### List features ###
cls ; Get-WindowsFeature | Where-Object InstallState -NE installed | select Name

cls ; Get-WindowsFeature *bit* | Where-Object InstallState -NE installed

cls ; Get-WindowsFeature | Where-Object InstallState -EQ installed | select name

### Add Roles ###
# 'NET-WCF*','rdc','Web-Url-Auth','Web-Windows-Auth','Web-Basic-Auth','Web-Mgmt-Compat','Web-IP-Security','Web-Client-Auth','Web-Digest-Auth','Web-Dyn-Compression','BITS'
Get-WindowsFeature *6* | select name

cls ; $Features = Get-WindowsFeature ('NET-WCF*','rdc','Web-Url-Auth','Web-Windows-Auth','Web-Basic-Auth','Web-Mgmt-Compat','Web-IP-Security','Web-Client-Auth','Web-Digest-Auth','Web-Dyn-Compression','BITS')
foreach ($Features in $Features){
if ($Features.InstallState -ne 'installed'){
Install-WindowsFeature $Features -IncludeAllSubFeature -IncludeManagementTools}
else {cls ; Write-Host Feature is already installed}}

### Remove Roles ###

cls ; $Features = Get-WindowsFeature ('AD-Domain-Services','FS-DFS-Replication','GPMC')
foreach ($Features in $Features){
if ($Features.InstallState -eq 'installed'){
Remove-WindowsFeature $Features -IncludeManagementTools}
else {cls ; Write-Host Feature is not installed}}

hostname

Restart-Computer -Force




cls ; Get-NetFirewallRule -DisplayName *file*  | Enable-NetFirewallRule
cls ; Get-NetFirewallRule -DisplayName *Instrumentation*   | Enable-NetFirewallRule

Get-NetFirewallRule

# On SCCM server

$SCCMRemoteControl = Get-NetFirewallRule -Name 'SCCM Remote Control' ; cls

if ( $SCCMRemoteControl.Enabled -eq 'true' )
{Remove-NetFirewallRule -Name 'SCCM Remote Control'} else
{
New-NetFirewallRule -Name 'SCCM Remote Control' -DisplayName 'SCCM Remote Control' -Enabled True -Profile Domain -Action Allow -Protocol TCP -LocalPort 2701 -Direction Inbound
}



# On DC server
### Logon to domain joined machine ###
exit 
Enter-PSSession -VMName "SCCM-DC1" -Credential $DomainCredential
cd\ ; Clear ; hostname ; whoami

cls ; Get-NetFirewallRule -DisplayName *file*  | Enable-NetFirewallRule
cls ; Get-NetFirewallRule -DisplayName *Instrumentation*   | Enable-NetFirewallRule

$SCCMClientNotification = Get-NetFirewallRule -Name 'SCCM Client Notification' ; cls

if ( $SCCMClientNotification.Enabled -eq 'true' )
{Remove-NetFirewallRule -Name '$SCCMClientNotification'} else
{
New-NetFirewallRule -Name 'SCCM Client Notification' -DisplayName 'SCCM Client Notification' -Enabled True -Profile Domain -Action Allow -Protocol TCP -LocalPort 10123 -Direction Outbound
}



