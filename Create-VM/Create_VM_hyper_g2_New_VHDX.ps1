Clear-Host
$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {
New-VM -Name "$VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"
Set-VM -Name $VM_Full_Name -DynamicMemory -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
}
else 
{Write-Host "We found that your VM is already created before"}


$Test_VHD_Path = Test-Path $VHDx_Path
if ( $Test_VHD_Path.Equals($false))
{
New-VHD -Path "$VHDx_Path" -SizeBytes (100GB) -Dynamic
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHDx_Path
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
}
else {
Write-Host "We found that your VHD is already created before"
}



### Attach ISO ###

$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 1 -ControllerLocation 0
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO


### Boot Order DVD first ###
$vmDVD=Get-VMDvdDrive -VMName $VM_Full_Name 
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name 
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDVD,$vmDrive,$vmNIC  

### Boot Order VHD first ###
$vmDVD= Get-VMDvdDrive -VMName $VM_Full_Name
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDrive,$vmDVD,$vmNIC 

### Start VM ###
Start-VM $VM_Full_Name

