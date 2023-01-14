Clear-Host ; cd\
[string]$Project_Name             = $Project_Name
[string]$Net_BIOS_Name            = 'Itoutbreak'
$Domain_Name                      = "$Net_BIOS_Name" + "." + "net"
[string]$ComputerName             = 'ROOTCA'
$VM_Name                          = "$Project_Name" + "-" + "$ComputerName"
[string]$LocalUserNameSRV         = 'administrator'
[string]$LocalUserNameCLT         = '.\admin'
$DomainUserName                   = "$Net_BIOS_Name\$LocalUserNameSRV"
$Password                         = ConvertTo-SecureString -String 'P@$$w0rd' -AsPlainText -Force
$LocalCredentialServer            = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LocalUserNameSRV,$Password
$LocalCredentialClient            = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LocalUserNameCLT,$Password
$DomainCredential                 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUserName,$Password

[string]$DatabasePath             = 'c:\windows\NTDS'
[string]$LogPath                  = 'c:\windows\NTDS'
[string]$SysvolPath               = 'c:\windows\SYSVOL'
[string]$StartRange               = '10.0.0.100' 
[string]$EndRange                 = '10.0.0.200'
[string]$DNS_Server               = '10.0.0.10'
$DC1_IPAddress  = ' ' ; $DC1_IPAddress  = '10.0.0.10'
$SVR1_IPAddress = ' ' ; $SVR1_IPAddress = '10.0.0.50'
hostname ; whoami


Clear-Host ; Get-VM $Project_Name*
Start-VM -VMName $VM_Name



### Logon to local machine "Server" ###
Enter-PSSession -VMName $VM_Name -Credential $LocalCredentialServer 
Enter-PSSession -VMName WSUS     -Credential $LocalCredentialServer 
### Logon to local machine "Client" ###
Enter-PSSession -VMName $VM_Name -Credential $LocalCredentialClient
### Logon to domain joined machine ###
Enter-PSSession -VMName $VM_Name -Credential $DomainCredential


cd\ ; Clear ; hostname ; whoami
Exit



Rename-Computer -NewName $ComputerName  -Restart -Force
Rename-Computer -NewName WSUS  -Restart -Force

Add-Computer -NewName $ComputerName -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force

Stop-Computer -Force
Restart-Computer -Force

Get-TimeZone *egy*

Clear-Host ; Set-TimeZone -Id "Egypt Standard Time" ; Get-TimeZone

Clear-Host ; ipconfig /all

Get-NetIPAddress

# Rename local Network Adaptor
$CSV_Path = ' ' ; $CSV_Path = 'c:\NetAdapter.csv'
########################
Clear-Host ; Get-NetAdapter| select Name,ifIndex | Export-Csv "$CSV_Path" -Force
Clear-Host ; $NetAdapter     = ' '        ; $NetAdapter     = Import-Csv "$CSV_Path" ; Clear-Host ; $NetAdapter
Clear-Host ; $InterfaceIndex = ' '        ; $InterfaceIndex = ($NetAdapter.ifIndex)
Clear-Host ; $InterfaceName  = ' '        ; $InterfaceName  = ($NetAdapter.Name)

$line = " "
foreach ( $Line in $InterfaceName ) {Get-NetIPInterface "$Line" -AddressFamily IPv4}

Clear-Host ; Get-NetAdapter -Name "$InterfaceName" | Rename-NetAdapter -NewName "$Domain_Name"

# Rename external Network Adaptor
########################
Clear-Host ; Get-NetAdapter| select Name,ifIndex | Export-Csv c:\NetAdapter.csv -Force
Clear-Host ; $NetAdapter = ' '            ; $NetAdapter = Import-Csv C:\NetAdapter.csv ; Clear-Host ; $NetAdapter
$ExternalNIC = Read-Host 'Enter your external NIC index number'

Clear-Host ; Get-NetAdapter -Name 'Ethernet' | Rename-NetAdapter -NewName 'External'
Clear-Host ; Get-NetIPInterface "$InterfaceName" -AddressFamily IPv4

## Set DC1 internal IP Address configuration
#####################==============
Clear-Host ; New-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndex" -IPAddress "$DC1_IPAddress" -PrefixLength '8'

Clear-Host ; Set-DnsClientServerAddress -ServerAddresses "$DNS_Server"     -InterfaceIndex "$InterfaceIndex"

Clear-Host ; Get-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndex" | select IPAddress | ft -AutoSize
Get-DnsClientServerAddress -InterfaceIndex "$InterfaceIndex" -AddressFamily 'IPv4' 

Clear-Host ; Remove-Item 'C:\NetAdapter.csv' -Force

## Set DC1 external IP Address configuration
#####################==============
Clear-Host ; New-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex $ExternalNIC -IPAddress $DC1_IPAddress -PrefixLength '8'

Clear-Host ; Set-DnsClientServerAddress -ServerAddresses "$DNS_Server"   -InterfaceIndex "$InterfaceIndex"

Clear-Host ; Get-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex "$InterfaceIndex" | select IPAddress | ft -AutoSize
Get-DnsClientServerAddress -InterfaceIndex "$InterfaceIndex" -AddressFamily 'IPv4' 

Clear-Host ; Remove-Item 'C:\NetAdapter.csv' -Force


## Set Server1 internal IP Address configuration
#####################==============
Clear-Host ; New-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex $InterfaceIndex -IPAddress $SVR1_IPAddress -PrefixLength '8'

Clear-Host ; Set-DnsClientServerAddress -ServerAddresses "$DNS_Server"     -InterfaceIndex "$InterfaceIndex"

Clear-Host ; Get-NetIPAddress -AddressFamily 'IPv4' -InterfaceIndex $InterfaceIndex | select IPAddress | ft -AutoSize
Get-DnsClientServerAddress -InterfaceIndex "$InterfaceIndex" -AddressFamily 'IPv4' 

Clear-Host ; Remove-Item 'C:\NetAdapter.csv' -Force

####################################################################################################################################

Get-NetIPInterface -InterfaceIndex 15 -AddressFamily IPv4

Clear-Host ; Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex

Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
Clear-Host ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8 ; Clear-Host ; ipconfig /all
Clear-Host ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8 ; Clear-Host ; ipconfig /all
Clear-Host ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8 ; Clear-Host ; ipconfig /all
Clear-Host ; New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.40 -PrefixLength 8 ; Clear-Host ; ipconfig /all
Clear-Host ; Set-DnsClientServerAddress -ServerAddresses $DNS_Server -InterfaceIndex $InterfaceIndex ; Clear-Host ; ipconfig /all

New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.30 -PrefixLength 8
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.100 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8



### List features ###
Clear-Host ; Get-WindowsFeature | Where-Object InstallState -NE installed | select Name

Clear-Host ; Get-WindowsFeature | Where-Object InstallState -EQ installed | select name

### Add Roles ###
# 'AD-Domain-Services','FS-DFS-Replication'
# 'AD-Certificate','ADCS-Cert-Authority','ADCS-Web-Enrollment'
# 'Windows-Server-Backup','Web-Server','RemoteAccess','DHCP'

Clear-Host ; $Features = ' ' ; $Features = Get-WindowsFeature 'AD-Domain-Services','FS-DFS-Replication'
Clear-Host ; $Features = ' ' ; $Features = Get-WindowsFeature 'Windows-Server-Backup'
Clear-Host ; $Features = ' ' ; $Features = Get-WindowsFeature 'DHCP'
Clear-Host ; $Features = ' ' ; $Features = Get-WindowsFeature 'DHCP','Windows-Server-Backup'
Clear-Host ; $Features = ' ' ; $Features = Get-WindowsFeature 'AD-Certificate','ADCS-Cert-Authority'

$Features.InstallState -eq 'installed'

foreach ($Feature in $Features){
if ($Feature.InstallState -ne 'installed'){
Install-WindowsFeature -Name $Feature -IncludeAllSubFeature -IncludeManagementTools}
else {Clear-Host ; Write-Host Feature is already installed}}




#### DHCP ####
Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -Name 'Scope1' -State Active -Type Both  -SubnetMask '255.0.0.0' 

Set-DhcpServerv4OptionValue -DnsServer $DNS_Server

Add-DhcpServerInDC -DnsName $ComputerName -Confirm


### Remove Roles ###

Clear-Host ; $Features = Get-WindowsFeature ('AD-Domain-Services','FS-DFS-Replication','GPMC')
foreach ($Features in $Features){
if ($Features.InstallState -eq 'installed'){
Remove-WindowsFeature $Features -IncludeManagementTools}
else {Clear-Host ; Write-Host Feature is not installed}}

hostname

Restart-Computer -Force


### Promote First Forest ###
Clear-Host ;Install-ADDSForest -DomainName $Domain_Name -DomainNetbiosName $Net_BIOS_Name -ForestMode WinThreshold -DomainMode WinThreshold -InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -Force

Install-ADDSDomainController -DomainName $Net_BIOS_Name -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -InstallDns -Force -Credential $DomainCredential

Add-Computer -NewName $ComputerName -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force
Add-Computer -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force




dcdiag /test:dns /v /s:itoutbreak.net /DnsBasic

