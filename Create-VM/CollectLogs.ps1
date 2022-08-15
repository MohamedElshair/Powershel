$Ports = ("53","135","88","389")
#53  --> DNS
#135 --> RPC Locator
#88  --> Kerberos
#389 --> LDAP
cls
foreach ($Ports in $Ports)
{
Test-NetConnection "DC name" -Port $Ports
}



$Testpath = Test-Path  'C:\CollectLogs.ps1'

if ($Testpath -eq $true )
{
Remove-Item -Path C:\CollectLogs.ps1 -Force
New-Item -Path C:\ -Name CollectLogs.ps1 -ItemType File -Force
}
else
{
New-Item -Path C:\ -Name CollectLogs.ps1 -ItemType File -Force
}



$content1={c: ; cd\ ;cls
$HostName      = hostname
$getadcomputer = Get-ADComputer $HostName | select name,ObjectGUID,sid
$w32tm         = w32tm /query /status
$whoamiupn     = whoami /upn
$whoamiGroups  = whoami /Groups
$Date = Get-Date -Format 'dd.MMMM.yy   HH.mm.ss'
$folderFullName  = "MicrosoftLogs" + "   " + "$Date"


New-Item "$folderFullName" -ItemType directory
New-Item "$folderFullName\$HostName-MainInfo.txt" -ItemType file
New-Item "$folderFullName\$HostName-DFS.txt" -ItemType file
New-Item "$folderFullName\$HostName-ComputerInfo.txt" -ItemType file
New-Item "$folderFullName\$HostName-Services.txt" -ItemType file
New-Item "$folderFullName\$HostName-LOGS" -ItemType Directory
New-Item "$folderFullName\$HostName-Events" -ItemType Directory
New-Item "$folderFullName\$HostName-Replication" -ItemType Directory

Copy-Item 'C:\Windows\debug\*.log' $folderFullName

$Logfiles = ls "c:\$folderFullName\*.log" | Move-Item -Destination "c:\$folderFullName\$HostName-LOGS" -Force

Copy-Item 'C:\Windows\System32\Winevt\Logs\Application.evtx' "c:\$folderFullName\$HostName-Events\$HostName-Application.evtx" -Force
Copy-Item 'C:\Windows\System32\Winevt\Logs\DFS Replication.evtx' "c:\$folderFullName\$HostName-Events\$HostName-DFS Replication.evtx" -Force
Copy-Item 'C:\Windows\System32\Winevt\Logs\Directory Service.evtx' "c:\$folderFullName\$HostName-Events\$HostName-Directory Service.evtx" -Force
Copy-Item 'C:\Windows\System32\Winevt\Logs\DNS Server.evtx' "c:\$folderFullName\$HostName-Events\$HostName-DNS Server.evtx" -Force
Copy-Item 'C:\Windows\System32\Winevt\Logs\System.evtx' "c:\$folderFullName\$HostName-Events\$HostName-System.evtx" -Force
Copy-Item 'C:\Windows\System32\Winevt\Logs\Security.evtx' "c:\$folderFullName\$HostName-Events\$HostName-Security.evtx" -Force

Get-ComputerInfo > c:\$folderFullName\$HostName-ComputerInfo.txt

$NTDS=cmd.exe /c "sc query ntds"
$netlogon=cmd.exe /c "sc query netlogon"
$lanman=cmd.exe /c "sc query lanmanworkstation"
$dns=cmd.exe /c "sc query dns"
$rpc=cmd.exe /c "sc query rpcss"

Add-Content "c:\$folderFullName\$HostName-Services.txt" $NTDS," " ,$netlogon," ",$lanman," ",$dns," ",$rpc

### Registery values ###
$Get-ItemProperty -Path  Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\
Get-ItemProperty -Path  Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\

$FSMO     = netdom query fsmo
Add-Content "$folderFullName\$HostName-MainInfo.txt" $HostName," ",$FSMO," ",$getadcomputer," ",$w32tm," ",$whoamiupn," ",$whoamiGroups

$ReplSum = "Replsum" + ' ' + 'for' + ' ' + "$HostName"
repadmin /replsum > "$folderFullName\$HostName-$ReplSum.txt"
Move-Item "c:\$folderFullName\$HostName-$ReplSum.txt" "$folderFullName\$HostName-Replication"

repadmin /showrepl * > "$folderFullName\$HostName-ShowreplAll.txt" 
Move-Item "c:\$folderFullName\$HostName-ShowreplAll.txt" "$folderFullName\$HostName-Replication"

dcdiag.exe  /v  > "$folderFullName\$HostName-DCDIAG.txt"

$DFSglobalstate      = dfsrmig.exe /getglobalstate
$DFSmigrationstate   = dfsrmig.exe /getmigrationstate
$DFSReplicationState = dfsrdiag.exe /ReplicationState

Add-Content "c:\$folderFullName\$HostName-DFS.txt" "$DFSglobalstate"," ",$DFSmigrationstate," ","$DFSReplicationState"
Move-Item "c:\$folderFullName\$HostName-DFS.txt" "$folderFullName\$HostName-Replication"

}

Add-Content -Value $content1 -Path C:\CollectLogs.ps1


