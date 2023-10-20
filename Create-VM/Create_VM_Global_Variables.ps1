### Global Variables ###

#region Set available drive letter
Clear-Host
$Global:DL                  = Read-Host 'Enter you project driver letter'
$Global:Drive_Letter        = $DL.Substring(0, 1)
$Global:Drive_Letter_collon = "$Drive_Letter" + ':\'
#endregion

#region Set project name and related folders
Clear-Host ; $Global:Project_Name = Read-Host 'Enter your project name'
$Global:Project_Path = ("$Drive_Letter_collon" + "$Project_Name") 

#endregion

#region Set export folder
Clear-Host
$Global:ExportFolderPath     = 'c:\Export'
$Global:TestExportFolderPath = Test-Path $ExportFolderPath

if ($TestExportFolderPath -eq $false) 
{New-Item -Name 'Export' -ItemType Directory -Path $Drive_Letter_collon -Force}
#endregion

#region Set VM names in one text file ####
Clear-Host
$Global:AskForVMNumber      = Read-Host "How many numbers of your project VM's"

$Global:VMTXTFileNAme       = 'VM.txt'
$Global:VMTXTPath           = "$ExportFolderPath\$VMTXTFileNAme"
$Global:TestExportVMTXTPath = Test-Path $VMTXTPath

if ($TestExportVMTXTPath -eq $true) 
{
Remove-Item -Path $VMTXTPath -Force
New-Item    -Path $ExportFolderPath -Name $VMTXTFileNAme -ItemType File
} 
Else 
{
New-Item    -Path $ExportFolderPath -Name $VMTXTFileNAme -ItemType File
}

Clear-Host

if ( $AskForVMNumber -ge 1) 
{ 

    $Global:VM_Name = for ( $Number = $AskForVMNumber.Length ; $Number -le $AskForVMNumber ; $Number ++ )
    {
    Read-Host "Please enter your vm number $Number name"
    }
 }

 Add-Content -Path $ExportFolderPath\VM.txt -Value $VM_Name -Force
#endregion

#region Set ISO path
Clear-Host ; $Global:ISOPATH = Read-Host 'Please enter your Windows ISO location path'
$Global:ISOLocalFolderPath     = 'c:\ISO'
$Global:TestISOLocalFolderPath = Test-Path $ISOFolderPath
if ($TestISOLocalFolderPath -eq $false) 
{New-Item -Name 'ISO' -ItemType Directory -Path $Drive_Letter_collon -Force}
$Global:ISOFiles = Get-ChildItem -Path $ISOLocalFolderPath -Filter *.iso
$Global:ISOName  = $ISOFiles.Name
#endregion

#region Create Project folder
$Test_Project_Path = Test-Path -Path $Global:Project_Path
if ($Test_Project_Path.Equals($false))
{
New-Item -ItemType Directory -Name $Global:Project_Name -Path $Global:Drive_Letter_collon
Clear-Host
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Global:Project_Path"
}
elseif ($Test_Project_Path.Equals($true))
{Clear-Host}
#endregion

#region Create Project switch
Clear-Host
$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Global:Project_Name))
{Write-Host "We found that your VM switch is already created before"}
else 
{New-VMSwitch "$Global:Project_Name" -SwitchType Private}
$Global:ProjectSwitch = Get-VMSwitch -Name $Project_Name | select Name,SwitchType
#endregion

#region Print Project summary
Clear-Host
Write-Host "         "
Write-Host "         "
Write-Host "Your drive is 

'$Drive_Letter_collon'"
Write-Host "         "
Write-Host "         "
Write-Host "Your project name is 

'$Project_Name'"
Write-Host "         "
Write-Host "         "
Write-Host "Your VM path is '$Project_Path'"
$VM_Name2 = $VM_Name
Write-Host "         "
Write-Host "         "
Write-Host Your VM name is  
foreach ( $VM_Name2 in $VM_Name2 ) {Write-Host $Project_Name-$VM_Name2}
Write-Host "         "
Write-Host "         "
Write-Host "Your project switch name is"
Get-VMSwitch -Name $Project_Name | select Name,SwitchType | ft -AutoSize
Remove-Item -Path $ExportFolderPath\$VMTXTFileNAme -Recurse -Force
#endregion

