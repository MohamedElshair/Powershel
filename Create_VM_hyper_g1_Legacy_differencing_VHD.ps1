################## Create Variables    ##################E

$Project_Name = Read-Host 'Please enter your project name'

$Drive_Letter_No_collon = Read-Host 'Please enter your drive letter'

$Drive_Letter_collon = "$Drive_Letter_No_collon" + ':\'

$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")

$VM_Name = Read-Host 'Please enter your vm name'

$VM_Full_Name = "$Project_Name" + "-" + "$VM_Name"

$VM_Path = ("$Project_Path" + "\" + "$VM_Full_Name")

$VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhd")

Write-Host "Your project name is -- > $Project_Name"
Write-Host "Your drive letter is -- > $Drive_Letter_collon"

##################################################################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {
New-VM -Name "$VM_Full_Name" -Generation 1 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
}
else 
{Write-Host "We found that your VM is already created before"}

Remove-VMScsiController -VMName $VM_Full_Name -ControllerNumber 0
$ParentPath = Read-Host 'Please enter your main VHD path'
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
