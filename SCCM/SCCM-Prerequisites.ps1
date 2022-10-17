Clear-Host ; cd\
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

cls ; Get-WindowsFeature | Where-Object InstallState -EQ installed | select name

### Add Roles ###
# 'NET-WCF*','rdc','Web-Url-Auth','Web-Url-Auth','Web-Basic-Auth'

cls ; $Features = Get-WindowsFeature ('NET-WCF*','rdc','Web-Url-Auth','Web-Url-Auth','Web-Basic-Auth')
foreach ($Features in $Features){
if ($Features.InstallState -ne 'installed'){
Install-WindowsFeature $Features -IncludeAllSubFeature -IncludeManagementTools}
else {cls ; Write-Host Feature is already installed}}

#### DHCP ####
Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -Name 'Scope1' -State Active -Type Both  -SubnetMask '255.0.0.0' 

Set-DhcpServerv4OptionValue -DnsServer $DNS_Server

Add-DhcpServerInDC  -DnsName $ComputerName -Confirm


### Remove Roles ###

cls ; $Features = Get-WindowsFeature ('AD-Domain-Services','FS-DFS-Replication','GPMC')
foreach ($Features in $Features){
if ($Features.InstallState -eq 'installed'){
Remove-WindowsFeature $Features -IncludeManagementTools}
else {cls ; Write-Host Feature is not installed}}

hostname

Restart-Computer -Force