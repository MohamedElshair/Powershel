Get-WindowsFeature *back* | select name

Add-WindowsFeature "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature "Windows-Server-Backup" -IncludeAllSubFeature -IncludeManagementTools


Rename-Computer -NewName PDC -Restart -Force


Get-NetIPInterface  -AddressFamily IPv4
$InterfaceIndex = "3"
Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
Remove-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex
New-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8
Set-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex -IPAddress 10.0.0.10 -PrefixLength 8

Set-DnsClientServerAddress -ServerAddresses 127.0.0.1 -InterfaceIndex $InterfaceIndex


