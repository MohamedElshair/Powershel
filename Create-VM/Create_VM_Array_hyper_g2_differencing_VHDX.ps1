################## Create Variables    #################################
$VM_Name_Array = ("DC1","Router")

foreach ( $VM_Name_Array in $VM_Name_Array ) 
{

$Project_Name = "F2022"

$Drive_Letter_collon = "D:\"

$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")

$VM_Full_Name = "$Project_Name" + "-" + "$VM_Name_Array"

$VM_Path = ("$Project_Path" + "\" + "$VM_Full_Name")

$VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhdx")

################## Create Private Switch with your project name ##################

$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Project_Name))
{
Write-Host "We found that your VM switch is already created before"}
else 
{
New-VMSwitch "$Project_Name" -SwitchType Private
}

################## Create Project folder with your project name ##################

$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false))
{
New-Item -ItemType Directory -Name $Project_Name -Path $Drive_Letter_collon
}
elseif ($Test_Project_Path.Equals($true))
{
Write-Host "We found that Project Folder is already created before, You can find it under this path $Project_Path"
}

#################################################################################################################################


$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false))
{
New-VM -Name "$VM_Full_Name"  -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -DynamicMemory -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name
}
else 
{
Write-Host "We found that your VM is already created before"
}



$ParentPath = "d:\Main Hard Drives\Win_Srv_2022 (updated June 2022).vhdx"
$Test_VHD_Path = Test-Path $VHD_Path
$Test_ParentVHD_Path = Test-Path $ParentPath
if ( $Test_ParentVHD_Path.Equals($false))
{
Write-Host "No parent VHD found"
}
else 
{
new-vhd -Path "$VHD_Path" -ParentPath "$ParentPath"
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
}
### Boot Order VHD first ###
$vmDVD= Get-VMDvdDrive -VMName $VM_Full_Name
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDrive,$vmDVD,$vmNIC 


}




### Boot Order DVD first ###
$vmDVD=Get-VMDvdDrive -VMName $VM_Full_Name 
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name 
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name  -BootOrder $vmDVD,$vmDrive,$vmNIC  



### Attach ISO ###

$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 1 -ControllerLocation 0

Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 1 -Path $ISO


### Start VM ###
Start-VM $Project_Name*
