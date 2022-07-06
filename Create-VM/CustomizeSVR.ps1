$Project_Name = "F2022"
Get-VM $Project_Name*
Start-VM -VMName "F2022-DC2"


Enter-PSSession -VMName "F2022-DC2" -Credential (Get-Credential administrator)
Enter-PSSession -VMName "F2022-DC2" -Credential (Get-Credential itoutbreak\administrator)


Get-TimeZone *egy*

Set-TimeZone -Id "Egypt Standard Time"

Get-NetIPInterface  -AddressFamily IPv4
$InterfaceIndex = "6"
Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.20 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8

Set-DnsClientServerAddress -ServerAddresses 10.0.0.10 -InterfaceIndex $InterfaceIndex

Get-WindowsFeature *back* | select name

Add-WindowsFeature "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature "Windows-Server-Backup" -IncludeAllSubFeature -IncludeManagementTools


Rename-Computer -NewName DC2 -Restart -Force

$DatabasePath = "c:\windows\NTDS"
$LogPath = "c:\windows\NTDS"
$SysvolPath = "c:\windows\SYSVOL"

Install-ADDSForest -DomainName Itoutbreak.net -DomainNetbiosName Itoutbreak -ForestMode WinThreshold -DomainMode WinThreshold `
-InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath

Install-ADDSDomainController -DomainName Itoutbreak.local -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -InstallDns






