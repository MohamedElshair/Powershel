$global:VHD_Path = ("$Global:VM_Path" + "\" + "$Global:VM_Full_Name.vhd")
$Global:ParentPath = Read-Host 'Please enter your main VHD path'

### Create VM G1 connected to switch name equal to same project name ###
Clear-Host
$Test_Project_Path   = Test-Path -Path $Global:Project_Path
if ($Test_Project_Path.Equals($false))
{
New-Item -ItemType Directory -Name $Global:Project_Name -Path $Global:Drive_Letter_collon
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Global:Project_Path"
}
elseif ($Test_Project_Path.Equals($true))
{Write-Host "We found that Project Folder is already created before, You can find it under this path $Global:Project_Path"}


Clear-Host
$Test_VM_Path   = Test-Path -Path $Global:VM_Path
if ($Test_VM_Path.Equals($false))
{
New-VM -Name "$Global:VM_Full_Name" -Generation 1 -MemoryStartupBytes 2GB  -NoVHD -Path "$Global:VM_Path" -SwitchName "$Global:Project_Name"
Set-VM -Name $Global:VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard
Set-VM -Name $Global:VM_Full_Name -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes 2GB
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $Global:VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $Global:VM_Full_Name
}
else {}


Remove-VMScsiController -VMName $Global:VM_Full_Name -ControllerNumber 0
$Test_VHD_Path = Test-Path $Global:VHD_Path
$Test_ParentVHD_Path = Test-Path $Global:ParentPath
if ( $Test_ParentVHD_Path.Equals($false)){
Write-Host "No parent VHD found"}
else {
new-vhd -Path "$Global:VHD_Path" -ParentPath "$Global:ParentPath"
Add-VMHardDiskDrive -VMName $Global:VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $Global:VHD_Path
Remove-VMNetworkAdapter -VMName $Global:VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $Global:VM_Full_Name -SwitchName $Global:Project_Name}
 

Start-VM $Global:VM_Full_Name
