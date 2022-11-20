$CSV_Path = 'C:\Mail Alias\Mail-Alias.csv'

$ImportedUsers = Import-Csv  "$CSV_Path"


foreach ( $user in $ImportedUsers ) 
{
Set-ADUser ($user.Name)  -Clear ProxyAddresses -Server dc16.scb.local 
Set-Mailbox ($user.Name)  -EmailAddresses $user.mailexternal,$user.Mailnumbers,$user.mailinternal}


Set-Mailbox Aly.Elmenshawy  -EmailAddresses $user.mailexternal,$user.Mailnumbers,$user.mailinternal

# Modify ProxyAddresses for 1 users

$UserName       = "Hazem.Abd El-Hadi"
$SecretNumber   = "954349"

$DC             = "dc16.scb.local"
$LocalSuffix    = "@scb.local"
$ExternalSuffix = "@scbank.com.eg"

cls ; Get-ADUser $UserName -Properties * -Server $DC | select Name,mail,ProxyAddresses


Set-ADUser  $UserName  -Clear ProxyAddresses -Server $DC
Set-Mailbox $UserName  -EmailAddresses "$UserName$ExternalSuffix","$SecretNumber$ExternalSuffix","$UserName$LocalSuffix"

