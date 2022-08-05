Clear-Host
cd\
$Project_Name  = $Project_Name
$Net_BIOS_Name = "Itoutbreak"
$Domain_Name   = "$Net_BIOS_Name" + "." + "net"
$ComputerName   = "DC1"
$VM_Name       = "$Project_Name" + "-" + $ComputerName


$DatabasePath = "c:\windows\NTDS"
$LogPath = "c:\windows\NTDS"
$SysvolPath = "c:\windows\SYSVOL"

$Password = Read-Host -AsSecureString
hostname


Get-VM $Project_Name*
Start-VM -VMName $VM_Name


Enter-PSSession -VMName $VM_Name -Credential (Get-Credential administrator)
Enter-PSSession -VMName $VM_Name -Credential (Get-Credential $Net_BIOS_Name\administrator)




Rename-Computer -NewName $ComputerName  -Restart -Force

Stop-Computer -Force

Get-TimeZone *egy*

Set-TimeZone -Id "Egypt Standard Time"

Get-NetIPAddress
Get-NetIPInterface  -AddressFamily IPv4
$InterfaceIndex = "2"
Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8

Set-DnsClientServerAddress -ServerAddresses 10.0.0.10 -InterfaceIndex $InterfaceIndex

Get-WindowsFeature *ca* | select name
Get-WindowsFeature | Where-Object InstallState -EQ installed


### Add Roles ###
Add-WindowsFeature "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature "AD-Certificate"  -IncludeAllSubFeature -IncludeManagementTools

Add-WindowsFeature "Windows-Server-Backup" -IncludeAllSubFeature -IncludeManagementTools

### Remove Roles ###
Remove-WindowsFeature "AD-Domain-Services" -IncludeManagementTools -Restart



hostname

Restart-Computer -Force


### Promote First Forest ###
Install-ADDSForest -DomainName $Domain_Name -DomainNetbiosName $Net_BIOS_Name -ForestMode WinThreshold -DomainMode WinThreshold -InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -SafeModeAdministratorPassword $Password -Force

Install-ADDSDomainController -DomainName $Net_BIOS_Name -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -InstallDns -Credential (Get-Credential $Net_BIOS_Name\administrator)






