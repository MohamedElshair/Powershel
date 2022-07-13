Clear-Host
$Test_VM_Path   = Test-Path -Path $Global:VM_Path
if ($Test_VM_Path.Equals($false)) {
New-VM -Name "$Global:VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Global:Project_Path" -SwitchName "$Global:Project_Name"
Set-VM -Name $Global:VM_Full_Name -DynamicMemory -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $Global:VM_Full_Name
}
else 
{Write-Host "We found that your VM is already created before"}


$Test_VHD_Path = Test-Path $Global:VHDx_Path
if ( $Test_VHD_Path.Equals($false))
{
New-VHD -Path "$Global:VHDx_Path" -SizeBytes (100GB) -Dynamic
Add-VMHardDiskDrive -VMName $Global:VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $Global:VHDx_Path
Set-VM -Name $Global:VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $Global:VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $Global:VM_Full_Name
Add-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
}
else {
Write-Host "We found that your VHD is already created before"
}



### Attach ISO ###

$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 1 -ControllerLocation 0
Add-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO


### Boot Order DVD first ###
$vmDVD=Get-VMDvdDrive -VMName $Global:VM_Full_Name 
$vmDrive= Get-VMHardDiskDrive -VMName $Global:VM_Full_Name 
$vmNIC= Get-VMNetworkAdapter -VMName $Global:VM_Full_Name
Set-VMFirmware -VMName $Global:VM_Full_Name -EnableSecureBoot On -BootOrder $vmDVD,$vmDrive,$vmNIC  

### Boot Order VHD first ###
$vmDVD= Get-VMDvdDrive -VMName $Global:VM_Full_Name
$vmDrive= Get-VMHardDiskDrive -VMName $Global:VM_Full_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $Global:VM_Full_Name
Set-VMFirmware -VMName $Global:VM_Full_Name -EnableSecureBoot On -BootOrder $vmDrive,$vmDVD,$vmNIC 

### Start VM ###
Start-VM $Global:VM_Full_Name
