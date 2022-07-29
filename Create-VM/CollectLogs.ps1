c:
cd\
cls
$Date = Get-Date -Format 'dd.MMMM.yy   HH.mm.ss'
$folderFullName  = "MicrosoftLogs" + "   " + "$Date"
New-Item "$folderFullName" -ItemType directory
New-Item "$folderFullName\MainInfo.txt" -ItemType file
New-Item "$folderFullName\DFS.txt" -ItemType file

Copy-Item 'C:\Windows\debug\*.log' $folderFullName
Copy-Item 'C:\Windows\System32\Winevt\Logs\Application.evtx' $folderFullName
Copy-Item 'C:\Windows\System32\Winevt\Logs\DFS Replication.evtx' $folderFullName
Copy-Item 'C:\Windows\System32\Winevt\Logs\Directory Service.evtx' $folderFullName
Copy-Item 'C:\Windows\System32\Winevt\Logs\DNS Server.evtx' $folderFullName
Copy-Item 'C:\Windows\System32\Winevt\Logs\System.evtx' $folderFullName

$HostName = hostname


$FSMO     = netdom query fsmo
Add-Content "$folderFullName\MainInfo.txt" $HostName," ",$FSMO

$ReplSum = "Replsum" + ' ' + 'for' + ' ' + "$HostName"
repadmin /replsum > "$folderFullName\$ReplSum.csv"

repadmin /showrepl * > "$folderFullName\ShowreplAll.csv"

dcdiag.exe  /v  > "$folderFullName\DCDIAG.txt"

$DFSglobalstate      = dfsrmig.exe /getglobalstate
$DFSmigrationstate   = dfsrmig.exe /getmigrationstate
$DFSReplicationState = dfsrdiag.exe ReplicationState

Add-Content "$folderFullName\DFS.txt "$DFSglobalstate," ",$DFSmigrationstate," ",$DFSReplicationState


