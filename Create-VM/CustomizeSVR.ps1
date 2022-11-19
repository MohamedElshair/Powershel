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
$DC1_IPAddress = ' ' ; $DC1_IPAddress = '10.0.0.10'
hostname ; whoami


cls ; Get-VM $Project_Name*
Start-VM -VMName $VM_Name



### Logon to local machine "Server" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialServer 
Enter-PSSession -VMName "WSUS" -Credential $LocalCredentialServer 
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

# Rename local Network Adaptor
$CSV_Path = ' ' ; $CSV_Path = 'c:\NetAdapter.csv'
########################
cls ; Get-NetAdapter| select Name,ifIndex | Export-Csv "$CSV_Path" -Force
cls ; $NetAdapter = ' '            ; $NetAdapter = Import-Csv "$CSV_Path" ; cls ; $NetAdapter
cls ; $InterfaceIndexifIndex = ' ' ; $InterfaceIndexifIndex = ($NetAdapter.ifIndex)
cls ; $InterfaceName = ' '         ; $InterfaceName = ($NetAdapter.Name)

$line = " "
foreach ( $Line in $InterfaceName ) {Get-NetIPInterface "$Line" -AddressFamily IPv4}

cls ; Get-NetAdapter -Name "$InterfaceName" | Rename-NetAdapter -NewName "$Domain_Name"

# Rename external Network Adaptor
########################
cls ; Get-NetAdapter| select Name,ifIndex | Export-Csv c:\NetAdapter.csv -Force
cls ; $NetAdapter = ' '            ; $NetAdapter = Import-Csv C:\NetAdapter.csv ; cls ; $NetAdapter
$ExternalNIC = Read-Host 'Enter your external NIC index number'

cls ; Get-NetAdapter -Name 'Ethernet' | Rename-NetAdapter -NewName 'External'
cls ; Get-NetIPInterface "$InterfaceName" -AddressFamily IPv4

## Set DC1 internal IP Address configuration
#####################==============
cls ; New-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndexifIndex" -IPAddress "$DC1_IPAddress" -PrefixLength '8'

cls ; Set-DnsClientServerAddress -ServerAddresses "$DNS_Server"     -InterfaceIndex "$InterfaceIndex"

cls ; Get-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndexifIndex" | select IPAddress | ft -AutoSize
Get-DnsClientServerAddress -InterfaceIndex "$InterfaceIndex" -AddressFamily 'IPv4' 

cls ; Remove-Item 'C:\NetAdapter.csv' -Force

## Set DC1 external IP Address configuration
#####################==============
cls ; New-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$ExternalNIC" -IPAddress "$DC1_IPAddress" -PrefixLength '8'

cls ; Set-DnsClientServerAddress -ServerAddresses "$DNS_Server"     -InterfaceIndex "$InterfaceIndex"

cls ; Get-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndexifIndex" | select IPAddress | ft -AutoSize
Get-DnsClientServerAddress -InterfaceIndex "$InterfaceIndex" -AddressFamily 'IPv4' 

cls ; Remove-Item 'C:\NetAdapter.csv' -Force

####################################################################################################################################

Get-NetIPInterface -InterfaceIndex 15 -AddressFamily IPv4

cls ; Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex

Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8 ; cls ; ipconfig /all
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8 ; cls ; ipconfig /all
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8 ; cls ; ipconfig /all
cls ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.40 -PrefixLength 8 ; cls ; ipconfig /all
cls ; Set-DnsClientServerAddress -ServerAddresses $DNS_Server -InterfaceIndex $InterfaceIndex ; cls ; ipconfig /all

New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.30 -PrefixLength 8
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.100 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8



### List features ###
cls ; Get-WindowsFeature | Where-Object InstallState -NE installed | select Name

cls ; Get-WindowsFeature | Where-Object InstallState -EQ installed | select name

### Add Roles ###
# 'AD-Domain-Services','FS-DFS-Replication'
# 'AD-Certificate','ADCS-Cert-Authority','ADCS-Web-Enrollment'
# 'Windows-Server-Backup','Web-Server','RemoteAccess','DHCP'

cls ; $Features = ' ' ; $Features = Get-WindowsFeature ('AD-Domain-Services','FS-DFS-Replication')
cls ; $Features = ' ' ; $Features = Get-WindowsFeature ('Windows-Server-Backup')
cls ; $Features = ' ' ; $Features = Get-WindowsFeature ('DHCP')

$Features.InstallState -eq 'installed'

foreach ($Feature in $Features){
if ($Feature.InstallState -ne 'installed'){
Install-WindowsFeature "$Feature" -IncludeAllSubFeature -IncludeManagementTools}
else {cls ; Write-Host Feature is already installed}}


#### DHCP ####
Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -Name 'Scope1' -State Active -Type Both  -SubnetMask '255.0.0.0' 

Set-DhcpServerv4OptionValue -DnsServer $DNS_Server

Add-DhcpServerInDC -DnsName $ComputerName -Confirm


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

Add-Computer -NewName $ComputerName -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force
Add-Computer -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force




dcdiag /test:dns /v /s:itoutbreak.net /DnsBasic

