### Global Variables ###
#### Set Available drive letter ####
Clear-Host
$Drive_Letter               = Read-Host 'Enter you project driver letter only'
$Global:Project_Name        = Read-Host 'Enter your project name '
$Global:VM_Name             = Read-Host 'Please enter your vm name'
$Global:Project_Path        = ("$Global:Drive_Letter_collon" + "$Project_Name") 
$Global:Drive_Letter_collon = "$Drive_Letter" + ':\'
$Global:VM_Full_Name        = "$Global:Project_Name" + "-" + "$Global:VM_Name"
$Global:VM_Path             = ("$Global:Project_Path" + "\" + "$Global:VM_Full_Name")
$Test_Drive                 = Test-path $Global:Drive_Letter_collon
$global:VHD_Path            = ("$Global:VM_Path" + "\" + "$Global:VM_Full_Name.vhd")
$global:VHDx_Path           = ("$Global:VM_Path" + "\" + "$Global:VM_Full_Name.vhdx")

Clear-Host

if ($Test_Drive.Equals($true)){
Clear-Host
Write-Host 'You Drive is set to' "$Global:Drive_Letter_collon"}
else{
    Clear-Host
    $Drive_Letter               = Read-Host 'Enter you project driver letter only'
    $Global:Drive_Letter_collon = "$Drive_Letter" + ':\'
    $Test_Drive                 = Test-path $Global:Drive_Letter_collon
    Clear-Host}
    if ($Test_Drive.Equals($true)){
    Clear-Host
    Write-Host 'You Drive is set to' "$Global:Drive_Letter_collon"}
        else{
        Clear-Host
        $Drive_Letter               = Read-Host 'Enter you project driver letter only'
        $Global:Drive_Letter_collon = "$Drive_Letter" + ':\'
        $Test_Drive                 = Test-path $Global:Drive_Letter_collon
        Clear-Host}
            if ($Test_Drive.Equals($true)){
        Clear-Host
        Write-Host 'You Drive is set to' "$Global:Drive_Letter_collon"}
            else {Write-Host "you tried 3 wrong times, Please try again later"}

##### Create Project folder #####        
$Test_Project_Path = Test-Path -Path $Global:Project_Path
if ($Test_Project_Path.Equals($false))
{
New-Item -ItemType Directory -Name $Global:Project_Name -Path $Global:Drive_Letter_collon
Clear-Host
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Global:Project_Path"
}
elseif ($Test_Project_Path.Equals($true))
{Clear-Host}

###### Create Project Private switch ######        
Clear-Host
$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Global:Project_Name))
{Write-Host "We found that your VM switch is already created before"}
else 
{New-VMSwitch "$Global:Project_Name" -SwitchType Private}

####### Print Project summary #######   
Clear-Host
Write-Host "         "
Write-Host "         "
Write-Host "Your drive is '$Global:Drive_Letter_collon'"
Write-Host "Your project name is '$Global:Project_Name'"
Write-Host "Your project private switch name is '$Global:Project_Name'"
Write-Host "Your VM name is  '$Global:VM_Full_Name'"
Write-Host "Your VM path is '$Global:VM_Path'"
Write-Host "         "
Write-Host "         "
        
