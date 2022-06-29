
# This script will create a virtual machine on Hyper-v.
# All Rights reserved to Mohamed Elshair www.itoutbreak.com

### Steps ###
# 1- Create VM without VHD.
# 2- Create VM Hard Desk.
# 3- Customize VM.
# 4- Install OS
################## Create Variables    ##################E

$Project_Name = Read-Host 'Please enter your project name'

$Drive_Letter_No_collon = Read-Host 'Please enter your drive letter'

$Drive_Letter_collon = "$Drive_Letter_No_collon" + ':\'

$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")

$VM_Name = Read-Host 'Please enter your vm name'

$VM_Full_Name = "$Project_Name" + "-" + "$VM_Name"

$VM_Path = ("$Project_Path" + "\" + "$VM_Full_Name")

$VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhdx")

Write-Host "Your project name is -- > $Project_Name"
Write-Host "Your drive letter is -- > $Drive_Letter_collon"

##################################################################################

################## Create Private Switch with your project name ##################

$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Project_Name)){Write-Host "We found that your VM switch is already created before"}
else {New-VMSwitch "$Project_Name" -SwitchType Private}

################## Create Project folder with your project name ##################

$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false)){
New-Item -ItemType Directory -Name $Project_Name -Path $Drive_Letter_collon
Write-Host "We made a Project Folder on behalf of you to create your VM's inside it, You can find it under this path $Project_Path"
explorer.exe $Project_Path}
elseif ($Test_Project_Path.Equals($true)){
Write-Host "We found that Project Folder is already created before, You can find it under this path $Project_Path"
explorer.exe $Project_Path}

#################################################################################################################################

##################     Create VM G2 connected to switch name that equal your project name ##########################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"}
else {Write-Host "We found that your VM is already created before"}

#################################################################################################################################


##################     Create VM G1 connected to switch name that equal your project name ##########################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Full_Name" -Generation 1 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"}
else {Write-Host "We found that your VM is already created before"}

#################################################################################################################################


##################     Create VM connected to switch name that equal your VM name ##############################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$VM_Name"}
else {Write-Host "We found that your VM is already created before"}

###############################################################################################################################

##################     Create VM not connected to any swtiches   ##############################################################

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false)) {New-VM -Name "$VM_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path"}
else {Write-Host "We found that your VM is already created before"}

################################################################################################################################
### Create new VHD for G1 ###
Remove-VMScsiController -VMName $VM_Full_Name -ControllerNumber 0
$Test_VHD_Path = Test-Path $VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -Path $VHD_Path
Remove-VMNetworkAdapter -VMName $VM_Full_Name
Add-VMNetworkAdapter -IsLegacy 1  -VMName $VM_Full_Name -SwitchName $Project_Name}
else {Write-Host "No thing to do"}
################################################################################################################################


### Create differencing VHD for G1 #############################################################################################
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
 
################################################################################################################################



### Create new VHD for G2 #####################################################################################################
$Test_VHD_Path = Test-Path $VHD_Path
if ( $Test_VHD_Path.Equals($false)){
New-VHD -Path $VHD_Path -SizeBytes 100Gb -Dynamic
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path}
else {Write-Host "No thing to do"}

### Create differencing VHD for g2  ###########################################################################################
$ParentPath = Read-Host 'Please enter your main VHD path'
$Test_VHD_Path = Test-Path $VHD_Path
$Test_ParentVHD_Path = Test-Path $ParentPath
if ( $Test_ParentVHD_Path.Equals($false)){
Write-Host "No parent VHD found"}
else {new-vhd -Path "$VHD_Path" -ParentPath "$ParentPath"
Add-VMHardDiskDrive -VMName $VM_Full_Name -ControllerLocation 0 -ControllerNumber 0 -ControllerType SCSI -Path $VHD_Path}
 
 

### Attach ISO ###

$ISO_folder = Read-Host "Please enter the iso file folder path"
$ISO = Get-ChildItem $ISO_folder\*.iso
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1
Remove-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 1 -ControllerLocation 0
Add-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO
Set-VMDvdDrive -VMName $VM_Full_Name -ControllerNumber 0 -ControllerLocation 1 -Path $ISO

### Customize VM ###

Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)

### Boot Order DVD first ###
$vmDVD=Get-VMDvdDrive -VMName $VM_Full_Name 
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name 
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDVD,$vmDrive,$vmNIC  

### Boot Order VHD first ###
$vmDVD=Get-VMDvdDrive -VMName $VM_Full_Name
$vmDrive= Get-VMHardDiskDrive -VMName $VM_Full_Name  
$vmNIC= Get-VMNetworkAdapter -VMName $VM_Full_Name
Set-VMFirmware -VMName $VM_Full_Name -EnableSecureBoot On -BootOrder $vmDrive,$vmDVD,$vmNIC 


### Integration Services ###
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
### Network Apaptor for the project name ###
Add-VMNetworkAdapter -VMName $VM_Full_Name -SwitchName $Project_Name
###

### Network Apaptor for the vm name ###
Remove-VMNetworkAdapter -VMName $VM_Name
Add-VMNetworkAdapter -VMName $VM_Name -SwitchName $VM_Name


## start VM's ###
Get-VM -Name *$Project_Name* | Start-VM

####### Get vm name and id to add in remote desktop ##############

Get-VM | select Name,Id


####### Add vm to remote desktop connection manager ##############
Remove-Item -Path $Project_Path\$Project_Name.rdg -Force
New-Item -Path $Project_Path -Name "$Project_Name.rdg" -ItemType File
Get-ChildItem -Path $Project_Path -Name "$Project_Name.rdg" -File | ConvertTo-Xml

Add-Content -Path $Project_Path\$Project_Name.rdg `
-Value {<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.90" schemaVersion="3">
  <file>
    <credentialsProfiles />
    <properties>
      <expanded>True</expanded>
      <name>Itoutbreak</name>
    </properties>
    <server>
      <properties>
        <displayName>DC1</displayName>
        <connectionType>VirtualMachineConsoleConnect</connectionType>
        <vmId>e73707cd-f5c6-4979-bafe-3e398f7beab5</vmId>
        <name>localhost</name>
      </properties>
    </server>
  </file>
  <connected />
  <favorites />
  <recentlyUsed />
</RDCMan>}
