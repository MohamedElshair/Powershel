$FileName = " " ; $FileName = Read-Host 'Enter file name'
$ExportPath = " " ; $ExportPath = "c:\$FileName.csv"
$Server = " " ; $Server = 'dc16.scb.local'




Get-ADComputer -Filter * -Properties * -Server $Server  |   Where-Object Enabled -EQ $false |select DistinguishedName,DNSHostName,Enabled,PasswordLastSet | Export-Csv $ExportPath -NoTypeInformation

& $ExportPath

del $ExportPath
