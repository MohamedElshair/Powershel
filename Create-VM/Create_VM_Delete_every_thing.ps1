Clear-Host

Get-VM $Project_Name*      | Stop-VM -Force

Get-VM $Project_Name*      | Remove-VM -Force

Get-VMSwitch $Project_Name | Remove-VMSwitch -Force

Remove-Item -Path $Project_Path -Recurse -Force