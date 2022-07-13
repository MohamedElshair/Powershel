$VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhd")
$ParentPath = Read-Host 'Please enter your main VHD path'

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


Remove-VMScsiController -VMName $VM_Full_Name -ControllerNumber 0
$Test_VHD_Path = Test-Path $VHD_Path
$Test_ParentVHD_Path = Test-Path $ParentPath
if ( $Test_ParentVHD_Path.Equals($false)){
Write-Host "No parent VHD found"}
else {
new-vhd -Path "$VHD_Path" -ParentPath "$ParentPath"
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $VHD_Path
Remove-VMNetworkAdapter -VMName $VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $VM_Full_Name -SwitchName $Project_Name}
 

Start-VM $VM_Full_Name
