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


#### Create new VHD for G1 ###
Clear-Host
Remove-VMScsiController -VMName $Global:VM_Full_Name -ControllerNumber 0
$Test_VHD_Path = Test-Path $Global:VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $Global:VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $Global:VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $Global:VHD_Path
Remove-VMNetworkAdapter -VMName $Global:VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $Global:VM_Full_Name -SwitchName $Global:Project_Name}
else {Write-Host "No thing to do"}


### Attach ISO ###
Clear-Host
$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 1 -ControllerLocation 0
Add-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $Global:VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO



## start VM's ###
Get-VM -Name *$Global:Project_Name* | Start-VM






