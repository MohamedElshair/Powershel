c: ; cd\ ; Clear-Host

Get-VM $Project_Name*      | Stop-VM -Force

Get-VM $Project_Name*      | Remove-VM -Force

$VM_Switches = Get-VMSwitch | Out-String
if ($VM_Switches.Contains($Project_Name))
{
Get-VMSwitch $Project_Name | Remove-VMSwitch -Force}
else 
{}

$Test_Project_Path   = Test-Path -Path $Project_Path
if ($Test_Project_Path.Equals($false))
{}
elseif ($Test_Project_Path.Equals($true))
{Remove-Item -Path $Project_Path -Recurse -Force}

Write-Host "Every thing is deleted"