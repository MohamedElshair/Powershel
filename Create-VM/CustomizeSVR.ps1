Clear-Host ; cd\
$Project_Name             = $Project_Name
$Net_BIOS_Name            = 'Itoutbreak'
$Domain_Name              = "$Net_BIOS_Name" + "." + "net"
$ComputerName             = "DC1"
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


Get-VM $Project_Name*
Start-VM -VMName $VM_Name



### Logon to local machine "Server" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialServer 
Enter-PSSession -VMName "REAL22-ROUTER" -Credential $LocalCredentialServer 
### Logon to local machine "Client" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialClient
### Logon to domain joined machine ###
Enter-PSSession -VMName "$VM_Name" -Credential $DomainCredential


cd\ ; Clear ; hostname ; whoami



Rename-Computer -NewName $ComputerName  -Restart -Force
Rename-Computer -NewName WSUS  -Restart -Force

Add-Computer -NewName $ComputerName -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force

Stop-Computer -Force
Restart-Computer -Force

Get-TimeZone *egy*

cls ; Set-TimeZone -Id "Egypt Standard Time" ; Get-TimeZone

cls ; ipconfig /all

Get-NetIPAddress

Get-NetAdapter
$InterfaceIndex = "7"
Get-NetAdapter -Name 'Ethernet 2' | Rename-NetAdapter -NewName External

cls ; Get-NetIPInterface  -AddressFamily IPv4
Get-NetIPInterface -InterfaceIndex 6 -AddressFamily IPv4

cls ; Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex

Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.1 -PrefixLength 8 ; cls ; ipconfig /all
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8 ; cls ; ipconfig /all
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8 ; cls ; ipconfig /all
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.30 -PrefixLength 8
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.100 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8

cls ; Set-DnsClientServerAddress -ServerAddresses $DNS_Server -InterfaceIndex $InterfaceIndex ; cls ; ipconfig /all

### List features ###
cls ; Get-WindowsFeature | Where-Object InstallState -NE installed | select Name
cls ; Get-WindowsFeature | Where-Object InstallState -EQ installed | select name
cls ; Get-WindowsFeature | Where-Object InstallState -EQ installed


### Add Roles ###
# 'AD-Domain-Services','FS-DFS-Replication'
# 'AD-Certificate','ADCS-Cert-Authority','ADCS-Web-Enrollment'
# 'Windows-Server-Backup','Web-Server','RemoteAccess','DHCP'

cls ; $Features = Get-WindowsFeature ('DHCP')
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


### Promote First Forest ###
cls ;Install-ADDSForest -DomainName $Domain_Name -DomainNetbiosName $Net_BIOS_Name -ForestMode WinThreshold -DomainMode WinThreshold -InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -Force

Install-ADDSDomainController -DomainName $Net_BIOS_Name -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -InstallDns -Force -Credential $DomainCredential


Add-Computer -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force




dcdiag /test:dns /v /s:itoutbreak.net /DnsBasic

