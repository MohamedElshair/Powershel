
# This script will create virtual machine on Hyper-v.
# All rights reserver to Mohamed Elshair https://www.itoutbreak.com

### Steps ###
# 1- Create VM without VHD.
# 2- Create VM Hard Desk.
# 3- Customize VM.
# 4- Install OS
################## Create Variables    ##################E

$Project_Name = Read-Host = 'Please enter your project name'

$Drive_Letter_No_collon = Read-Host 'Please enter yourr drive letter'

$Drive_Letter_collon = "$Drive_Letter_No_collon" + ':\'

$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")

$VM_Name = Read-Host = 'Please enter your vm name'

$VM_Path = ("$Project_Path" + "\" + "$VM_Name")

$VHD_Path = ("$VM_Path" + "\" + "$VM_Name.vhdx")

Write-Host = "Your project name is $Project_Name"
Write-Host = "Your drive letter is $Drive_Letter_collon"

#########################################################

################## Create Private Switch ##################

$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Project_Name)){Write-Host "We found that your VM switch is already created before"}
else {New-VMSwitch -Name "$ProjectName" -SwitchType Private}

################## Create Project folder ##################

$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false)){
New-Item -ItemType Directory -Name $Project_Name -Path $Drive_Letter_collon
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Project_Path"
explorer.exe $Project_Path}
elseif ($Test_Project_Path.Equals($true)){
Write-Host "We found that Project Folder is already created before, You can find it under this path $Project_Path"
explorer.exe $Project_Path}

########################################################

##################     Create VM      ##################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$ProjectName"}
else {Write-Host "We found that your VM is already created before"}

########################################################

### Attach ISO ###

$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso | select Name | ft -HideTableHeaders | Out-String
Remove-VMDvdDrive -VMName $VM_Name -ControllerNumber 0 -ControllerLocation 1
Add-VMDvdDrive -VMName $VM_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO

### Customize VM ###

Set-VM -Name $VM_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
$Test_VHD_Path = Test-Path $VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $VM_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path}
else {Write-Host "No thing to do"}
 
### Boot Order ###
$vmDVD=Get-VMDvdDrive -VMName $VM_Name 
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Name
Set-VMFirmware -VMName $VM_Name -EnableSecureBoot On  -BootOrder $vmDVD,$vmDrive,$vmNIC  
### Integration Services ###
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Name 
### Network Apaptor ###
Remove-VMNetworkAdapter -VMName $VM_Name
Add-VMNetworkAdapter -VMName $VM_Name -SwitchName $Project_Name



