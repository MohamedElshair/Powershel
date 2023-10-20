################## Create Variables    #################################
#region Iso file
$CopyIsoFile = Read-Host 'Do you want to copy ISO file (Y/N) ?'
If ( $CopyIsoFile -eq 'Y' ) {
Import-Module BitsTransfer
Start-BitsTransfer -Source $ISOPATH\$ISOName -Destination $ISOLocalFolderPath -Description 'Copying ISO files' -DisplayName 'Copying ISO files'
}
#endregion


$VM_Name2 = $VM_Name
foreach ( $VM_Name2 in $VM_Name2 ) 
{

$VM_Full_Name = "$Project_Name-$VM_Name2"
$VHDx_Path = "$Project_Path\$VM_Full_Name\$VM_Full_Name.vhdx"
$VM_Path = "$Project_Path\$VM_Full_Name"
$Test_VM_Path   = Test-Path -Path $VM_Path


#region Create VM
if ($Test_VM_Path.Equals($false))
{

New-VM -Name $VM_Full_Name -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path $Project_Path -SwitchName $Project_Name
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 2 -Path "$ISOLocalFolderPath\$ISOName"
New-VHD -Path "$VHDx_Path" -SizeBytes (100GB) -Dynamic
Add-VMHardDiskDrive -VMName "$VM_Full_Name" -Path $VHDx_Path -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 1
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -DynamicMemory -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name

#region Boot Order CD first
$vmDVD= Get-VMDvdDrive -VMName $VM_Full_Name
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDVD,$vmDrive,$vmNIC 
#endregion

}
else 
{Write-Host "We found that your VM is already created before"}
#endregion
}






### Start VM ###
Start-VM $Project_Name*
