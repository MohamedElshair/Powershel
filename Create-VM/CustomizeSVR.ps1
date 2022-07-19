$Project_Name  = "F2022"
$Net_BIOS_Name = "Itoutbreak"
$Domain_Name   = "$Net_BIOS_Name" + "." + "net"
$VM_Name       = "F2022-DC1"

$DatabasePath = "c:\windows\NTDS"
$LogPath = "c:\windows\NTDS"
$SysvolPath = "c:\windows\SYSVOL"

Get-VM $Project_Name*
Start-VM -VMName $VM_Name


Enter-PSSession -VMName $VM_Name -Credential (Get-Credential administrator)
Enter-PSSession -VMName $VM_Name -Credential (Get-Credential $Net_BIOS_Name\administrator)


Stop-Computer -Force

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



Install-ADDSForest -DomainName $Net_BIOS_Name -DomainNetbiosName $Net_BIOS_Name -ForestMode WinThreshold -DomainMode WinThreshold `
-InstallDns -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath

Install-ADDSDomainController -DomainName $Net_BIOS_Name -DatabasePath $DatabasePath -LogPath $LogPath -SysvolPath $SysvolPath -InstallDns






