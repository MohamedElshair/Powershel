### Global Variables

$Global:Project_Name = "Forest2022"

$Global:Drive_Letter_collon = "D" + ':\'

$Global:Project_Path = ("$Drive_Letter_collon" + "$Project_Name")

$Global:VM_Name="DC1"

$Global:VM_Full_Name="$Project_Name" + "-" + "$VM_Name"

$Global:VM_Path = ("$Project_Path" + "\" + "$VM_Full_Name")

$Global:VHD_Path = ("$VM_Path" + "\" + "$VM_Full_Name.vhdx")