$Project_Name = Read-Host 'Please enter your project name'

$Drive_Letter_No_collon = Read-Host 'Please enter your drive letter'

$Drive_Letter_collon = "$Drive_Letter_No_collon" + ':\'

$Project_Path = ("$Drive_Letter_collon" + "$Project_Name")



$Test_RDG_File = Test-Path "$Project_Path\$Project_Name.rdg"
If ( $Test_RDG_File.Equals($true))
{
Remove-Item "$Project_Path\$Project_Name.rdg" -Force
New-Item -ItemType File -Path "$Project_Path\$Project_Name.rdg" -Force 
}
Else
{
New-Item -ItemType File -Path "$Project_Path\$Project_Name.rdg" -Force 
}





$vmsearch = Get-VM $Project_Name* | select Name | ft  -AutoSize -HideTableHeaders  > $Project_Path\vmname.txt -Force 

$vmsearch = Get-VM $Project_Name*  | select id   | ft  -AutoSize -HideTableHeaders  > $Project_Path\id.txt -Force 


$vmnames  = Get-Content $Project_Path\vmname.txt | Where { $_ } 

$vmid     = Get-Content $Project_Path\id.txt     | Where { $_ } 




$run = for ( $x=0 ; $x -ne $vmnames.Length ; $x++ ){ 
'<server>' 

'<properties>' 

'<displayName>' + $vmnames[$x].TrimEnd() + '</displayName>' 

'<connectionType>VirtualMachineConsoleConnect</connectionType>'   

'<vmId>'+ $vmid[$x] +'</vmId>' 

'<name>localhost</name>' 

'</properties>' 

'</server>' 
} 


$Content = @"
<?xml version="1.0" encoding="utf-8"?>
 <RDCMan programVersion="2.83" schemaVersion="3">
   <file>
     <credentialsProfiles />
     <properties>
      <expanded>False</expanded>
     <name>$Project_Name</name>
    </properties>
    <logonCredentials inherit="None">
      <profileName scope="Local">Custom</profileName>
      <userName>,\administrator</userName>
      <password>AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAA3SS/P85+nUKGzZWMDzzLoAAAAAACAAAAAAAQZgAAAAEAACAAAAAboJ2wSQ8W32iMQcp6zwGDSkp/M8QjMNB2/el4/plkdwAAAAAOgAAAAAIAACAAAACBIM19nIqmtyuhx3wuAC8HTAUkOK4nvPRIEkXTmYS30SAAAABqnfhPA07IxCCap4kDhvu4tua/gZprhIlu4Cm2mxsHOEAAAACIRigefdbn77g3LGwK5EIqn/y3DYX1UpSXF91Fcpt0npJZgTUbC+z+ahxBzq2WokQPe77oUEYMOZO9rYrGh1fO</password>
      <domain>,</domain>
    </logonCredentials>
    <remoteDesktop inherit="None">
      <sameSizeAsClientArea>False</sameSizeAsClientArea>
      <fullScreen>True</fullScreen>
      <colorDepth>24</colorDepth>
    </remoteDesktop>
    <displaySettings inherit="None">
      <liveThumbnailUpdates>True</liveThumbnailUpdates>
      <allowThumbnailSessionInteraction>True</allowThumbnailSessionInteraction>
      <showDisconnectedThumbnails>True</showDisconnectedThumbnails>
      <thumbnailScale>1</thumbnailScale>
      <smartSizeDockedWindows>True</smartSizeDockedWindows>
      <smartSizeUndockedWindows>True</smartSizeUndockedWindows>
    </displaySettings>
    $run
   </file>
   <connected />
   <favorites />
  <recentlyUsed />
  </RDCMan>
"@

Add-Content -Path "$Project_Path\$Project_Name.rdg" $Content


       
Remove-Item -Path $Project_Path\*.txt

Get-ChildItem "$Project_Path\*.rdg" | Rename-Item -NewName "$Project_Name.rdg"  





