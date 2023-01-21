################## Create Variables    #################################


$VM_Name_Array = 'DC1','CM01','CM02','Router','CLT01','CLT02'


Clear-Host ; foreach ( $VM_Name_Array in $VM_Name_Array ) {

$Project_Name = "SCCM"
$Drive_Letter_collon = "D:\"
$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")
$VM_Full_Name = "$Project_Name" + "-" + "$VM_Name_Array"
$VM_Path = ("$Project_Path" + "\" + "$VM_Full_Name")
$VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhdx")

################## Create Private Switch with your project name ##################

$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Project_Name))
{Write-Host "We found that your VM switch is already created before"}
else 
{New-VMSwitch "$Project_Name" -SwitchType Private}

################## Create Project folder with your project name ##################

$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false))
{New-Item -ItemType Directory -Name $Project_Name -Path $Drive_Letter_collon}
elseif ($Test_Project_Path.Equals($true))
{Write-Host "We found that Project Folder is already created before, You can find it under this path $Project_Path"}

#################################################################################################################################
$VHDX_Copy_From_Path = Read-Host Please enter the $VM_Name_Array VHDx path
$VHDX_Copy_To_Path   = $VM_Path

$Test_VM_Path   = Test-Path -Path $VM_Path
if ($Test_VM_Path.Equals($false))
{
New-VM -Name "$VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"
Import-Module BitsTransfer
Start-BitsTransfer -Source $VHDX_Copy_From_Path -Destination $VM_Path\$VM_Full_Name.vhdx -Description "Copy VHDX file" -DisplayName "Copy VHDX file"
Add-VMHardDiskDrive -VMName "$VM_Full_Name" -Path $VM_Path\$VM_Full_Name.vhdx -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 1
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -DynamicMemory -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name
}
else 
{New-VM -Name "$VM_Full_Name" -Generation 2 -MemoryStartupBytes 2GB  -NoVHD -Path "$Project_Path" -SwitchName "$Project_Name"
Import-Module BitsTransfer
Start-BitsTransfer -Source $VHDX_Copy_From_Path -Destination $VM_Path\$VM_Full_Name.vhdx -Description "Copy VHDX file" -DisplayName "Copy VHDX file"
Add-VMHardDiskDrive -VMName "$VM_Full_Name" -Path $VM_Path\$VM_Full_Name.vhdx -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 1
Set-VM -Name $VM_Full_Name -AutomaticCheckpointsEnabled 0 -DynamicMemory -CheckpointType Standard -MemoryMaximumBytes (2GB) -MemoryMinimumBytes (1GB) -MemoryStartupBytes (2GB)
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VM_Full_Name
Disable-VMIntegrationService -Name "Time Synchronization" -VMName $VM_Full_Name}

Set-VMFirmware -VMName $VM_Full_Name -BootOrder $vmDrive
Start-VM $VM_Full_Name
}








### Start VM ###
Start-VM $Project_Name*
