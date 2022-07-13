Get-VM $Global:Project_Name*      | Stop-VM -Force

Get-VM $Global:Project_Name*      | Remove-VM -Force

Get-VMSwitch $Global:Project_Name | Remove-VMSwitch -Force

Remove-Item -Path $Global:Project_Path -Recurse -Force