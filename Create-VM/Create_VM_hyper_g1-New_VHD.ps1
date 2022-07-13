### Create VM G1 connected to switch name equal to same project name ###
Clear-Host
$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false))
{
New-Item -ItemType Directory -Name $Project_Name -Path $Drive_Letter_collon
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Project_Path"
}
elseif ($Test_Project_Path.Equals($true))
{Write-Host "We found that Project Folder is already created before, You can find it under this path $Project_Path"}


Clear-Host
$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false))
{
New-VM -Name "$VM_Full_Name" -Generation 1 -MemoryStartupBytes 2GB  -NoVHD -Path "$VM_Path" -SwitchName "$Project_Name"
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard
Set-VM -Name $VM_Full_Name -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes 2GB
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name
}
else {}


#### Create new VHD for G1 ###
Clear-Host
Remove-VMScsiController -VMName $VM_Full_Name -ControllerNumber 0
$Test_VHD_Path = Test-Path $VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $VHD_Path
Remove-VMNetworkAdapter -VMName $VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $VM_Full_Name -SwitchName $Project_Name}
else {Write-Host "No thing to do"}


### Attach ISO ###
Clear-Host
$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 1 -ControllerLocation 0
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO



## start VM's ###
Get-VM -Name *$Project_Name* | Start-VM






