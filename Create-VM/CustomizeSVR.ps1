Clear-Host ; cd\
$Project_Name             = $Project_Name
$Net_BIOS_Name            = 'Itoutbreak'
$Domain_Name              = "$Net_BIOS_Name" + "." + "net"
$ComputerName             = "DC2"
$VM_Name                  = "$Project_Name" + "-" + $ComputerName
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
### Logon to local machine "Client" ###
Enter-PSSession -VMName "$VM_Name" -Credential $LocalCredentialClient
### Logon to domain joined machine ###
Enter-PSSession -VMName "$VM_Name" -Credential $DomainCredential


cd\ ; Clear ; hostname ; whoami



Rename-Computer -NewName $ComputerName  -Restart -Force

Add-Computer -NewName $ComputerName -DomainName $Domain_Name -Credential $DomainCredential -Restart -Force

Stop-Computer -Force

Get-TimeZone *egy*

Set-TimeZone -Id "Egypt Standard Time"

clear ; ipconfig /all
ipconfig /release ; ipconfig /renew
Get-NetIPAddress
Get-NetIPInterface  -AddressFamily IPv4
$InterfaceIndex = "3"
Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.30 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8

Set-DnsClientServerAddress -ServerAddresses $DNS_Server -InterfaceIndex $InterfaceIndex

### List features ###
Get-WindowsFeature *web* | select name
Get-WindowsFeature | Where-Object InstallState -EQ installed


### Add Roles ###
Add-WindowsFeature 'AD-Domain-Services'    -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature 'AD-Certificate'        -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature 'ADCS-Cert-Authority'   -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature 'ADCS-Cert-Authority','ADCS-Web-Enrollment'   -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature 'Windows-Server-Backup' -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature 'Web-Server' -IncludeAllSubFeature -IncludeManagementTools



#### DHCP ####
Add-WindowsFeature 'DHCP'                  -IncludeAllSubFeature -IncludeManagementTools

Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -Name 'Scope1' -State Active -Type Both  -SubnetMask '255.0.0.0' 

Set-DhcpServerv4OptionValue -DnsServer $DNS_Server

Add-DhcpServerInDC  -DnsName $ComputerName -Confirm



### Remove Roles ###
Remove-WindowsFeature 'AD-Domain-Services' -IncludeManagementTools -Restart

Remove-WindowsFeature 'ADCS-Cert-Authority','ADCS-Web-Enrollment'   -IncludeAllSubFeature -IncludeManagementTools



hostname

Restart-Computer -Force


### Promote First Forest ###
Install-ADDSForest -DomainName $Domain_Name -DomainNetbiosName $Net_BIOS_Name -ForestMode WinThreshold -DomainMode WinThreshold -InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -Force

Install-ADDSDomainController -DomainName $Net_BIOS_Name -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -InstallDns -Force -Credential $DomainCredential








