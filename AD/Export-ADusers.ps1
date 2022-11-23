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





Get-ADUser -Identity kareem.essam  -Properties *  | select SamAccountName,UserPrincipalName,telephoneNumber,proxyAddresses,empid | Export-Csv "$ExportPathPredifined\test.csv" -NoTypeInformation -Verbose


Get-ADUser -Identity kareem.essam -Properties proxyaddresses | select name, @{L=’ProxyAddress_1′; E={$_.proxyaddresses[0]}}, @{L=’ProxyAddress_2′;E={$_.ProxyAddresses[1]}} | Export-Csv "$ExportPathPredifined\test.csv" -NoTypeInformation -Verbose



Get-ADUser -Identity 'kareem.essam'  -Properties * | clip





Get-ADUser -Filter *  -Properties *  | select SamAccountName,UserPrincipalName,telephoneNumber,employeeID,mail,proxyAddresses| Export-Csv "c:\test.csv" -NoTypeInformation -Verbose

Get-ADUser -Filter 'Enabled -eq "True"'  -Properties SamAccountName,UserPrincipalName,employeeID,mail,proxyaddresses -Server 'dc16.scb.local'  | Select-Object SamAccountName,UserPrincipalName,employeeID,mail, @{L = "ProxyAddresses"; E = { ($_.ProxyAddresses -like 'smtp:*') -join ";"}} | export-csv c:\proxy.csv -NoTypeInformation -Delimiter ';'


Get-ADUser -Filter 'Enabled -eq "True"'  -Properties SamAccountName,UserPrincipalName,employeeID -Server 'dc16.scb.local' | Where-Object employeeID -EQ $null | Export-Csv 'c:\empty.csv' -NoTypeInformation



#Get-ADUser -Filter 'Enabled -eq "True"'  -Properties SamAccountName,employeeID,mail,proxyAddresses -Server 'dc16.scb.local'  | Select-Object SamAccountName,UserPrincipalName,employeeID,mail, @{L = "ProxyAddresses"; E = { ($_.ProxyAddresses -like 'smtp:*') -join ";"}} | export-csv 'C:\Users\mohamed.elshair\Desktop\Users AD.csv' -NoTypeInformation -Delimiter ';'



Get-ADUser -Filter 'Enabled -eq "True"' -Properties SamAccountName,employeeID,mail,proxyAddresses -Server 'dc16.scb.local' `
| Where-Object { $_.DistinguishedName -notmatch 'OU=External-Companies,OU=Main Systems,DC=scb,DC=local' `
  -and ($_.DistinguishedName -notmatch 'OU=USER,OU=External Service VPN,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Admin-Super,OU=user,OU=system admin,OU=IT,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Service Account,OU=IT,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'CN=Monitoring Mailboxes,CN=Microsoft Exchange System Objects,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'CN=Users,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=User,OU=Disable,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=KIOSK,OU=Admin-Support,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=admin,OU=IT,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=WEBEX,OU=Admin-Support,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=RATES,OU=Admin-Support,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=OpenShift,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Digital Screen,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Service Accounts,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=admin,OU=IT,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Test,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=USERS,OU=MaximoUsers,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Maximo,OU=Head Offic,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=ERM Credit Risk,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Users,OU=DataGear,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=SAS,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=SAS,OU=Main Systems,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'CN=Managed Service Accounts,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Admin Affairs,OU=USERS,OU=SADAT,OU=Branches,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Agents,OU=Users,OU=Call-Center,OU=Head Office Departments,DC=scb,DC=local') `
  -and ($_.DistinguishedName -notmatch 'OU=Exchange Groups,DC=scb,DC=local') } `
| Select-Object SamAccountName,UserPrincipalName,employeeID,mail, @{L = "ProxyAddresses"; E = { ($_.ProxyAddresses -like 'smtp:*') -join ";"}} `
| export-csv 'C:\Users\mohamed.elshair\Desktop\Users AD.csv' -NoTypeInformation -Delimiter ';'




& 'C:\Users\mohamed.elshair\Desktop\Users AD.csv'











