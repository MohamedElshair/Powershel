
### Create VM G2 connected to switch name that equal your project name ##########################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Global:Project_Path" -SwitchName "$Global:Project_Name"}
else {Write-Host "We found that your VM is already created before"}

#################################################################################################################################


##################     Create VM connected to switch name that equal your VM name ##############################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Global:Project_Path" -SwitchName "$VM_Name"}
else {Write-Host "We found that your VM is already created before"}

###############################################################################################################################


##################     Create VM not connected to any swtiches   ##############################################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Global:Project_Path"}
else {Write-Host "We found that your VM is already created before"}

### Create differencing VHD for g2  ###########################################################################################
$ParentPath = Read-Host 'Please enter your main VHD path'
$Test_VHD_Path = Test-Path $VHD_Path
$Test_ParentVHD_Path = Test-Path $ParentPath
if ( $Test_ParentVHD_Path.Equals($false)){
Write-Host "No parent VHD found"}
else {new-vhd -Path "$VHD_Path" -ParentPath "$ParentPath"
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path}
 
 
 
### Create differencing VHD for G1 #############################################################################################
Remove-VMScsiController -VMName $Global:VM_Full_Name -ControllerNumber 0
$ParentPath = Read-Host 'Please enter your main VHD path'
$Test_VHD_Path = Test-Path $VHD_Path
$Test_ParentVHD_Path = Test-Path $ParentPath
if ( $Test_ParentVHD_Path.Equals($false)){
Write-Host "No parent VHD found"}
else {
new-vhd -Path "$VHD_Path" -ParentPath "$ParentPath"
Add-VMHardDiskDrive -VMName $Global:VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $VHD_Path
Remove-VMNetworkAdapter -VMName $Global:VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $Global:VM_Full_Name -SwitchName $Global:Project_Name}
 
################################################################################################################################




### Create new VHD for G2 #####################################################################################################
$Test_VHD_Path = Test-Path $VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $Global:VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path}
else {Write-Host "No thing to do"}



### Network Apaptor for the vm name ###
Remove-VMNetworkAdapter -VMName $Global:VM_Name
Add-VMNetworkAdapter -VMName $Global:VM_Name -SwitchName $Global:VM_Name
