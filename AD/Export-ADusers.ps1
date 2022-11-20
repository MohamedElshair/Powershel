$ExportPath =  Read-Host 'Enter you Export path'

$ExportFileName = 'ITBranchUsers.csv'

$ExportPathPredifined = 'C:\Users\mohamed.elshair\Desktop'

$ExportPathFull = "$ExportPathPredifined\$ExportFileName"

$SearchBase = 'OU=IT,DC=scb,DC=local'


$TestExportFileName = Test-Path $ExportPathFull

if  ($TestExportFileName -eq $true) 
{ 
rm  $ExportPathFull
Get-ADUser -Filter * -Properties * -SearchBase $SearchBase  | select SamAccountName,UserPrincipalName,telephoneNumber  | Export-Csv $ExportPathFull -NoTypeInformation
}
else 
{Get-ADUser -Filter * -Properties * -SearchBase $SearchBase  | select SamAccountName,UserPrincipalName,telephoneNumber  | Export-Csv $ExportPathFull -NoTypeInformation}

& $ExportPathFull





Get-ADUser -Identity kareem.essam  -Properties *  | select SamAccountName,UserPrincipalName,telephoneNumber,proxyAddresses | Export-Csv "$ExportPathPredifined\test.csv" -NoTypeInformation -Verbose


Get-ADUser -Identity kareem.essam -Properties proxyaddresses | select name, @{L=’ProxyAddress_1′; E={$_.proxyaddresses[0]}}, @{L=’ProxyAddress_2′;E={$_.ProxyAddresses[1]}} | Export-Csv "$ExportPathPredifined\test.csv" -NoTypeInformation -Verbose