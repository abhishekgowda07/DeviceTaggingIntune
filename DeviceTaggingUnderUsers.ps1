Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Scopes "Directory.AccessAsUser.All"
Select-MgProfile Beta
Connect-AzureAD


$Results = @()
$Currentdt = Get-Date -Format "yyyyMMdd_HH_mm"
$DataPath = "C:\temp\Devices_Tagged_" + "$Currentdt.csv"
$FullDataPath = $DataPath
$Dev=Import-Csv -Path C:\temp\list_of_user_ids.csv
$Devices1=$Dev.UserId
$Devices=ForEach($ids in $Devices1){
Get-AzureADUserRegisteredDevice -ObjectId $ids}
#Write-Host($Devices)
ForEach($Device in $Devices){
  #Write-Host($Device.DeviceId)
  $user=Get-AzureADDeviceRegisteredUser -ObjectId $Device.ObjectId
  $UserId=$user.ObjectId
  if($UserId){
  [array]$mgu=(Get-MgUser -UserId $UserId).OnPremisesExtensionAttributes.ExtensionAttribute13}
  If ($user) {
  #$ext=$mgu[0].ToString()
  #Write-Host($ext)
   $Properties = @{
   DeviceName=$Device.DisplayName
   UserName=$user.DisplayName
   }
   $Results += New-Object psobject -Property $properties
         Write-Host ("Device {0} owned by {1}" -f $Device.DisplayName, $user.DisplayName)
            $Attributes = @{
           "extensionAttributes" = @{
           "extensionAttribute13" = "EX13" }
         }  | ConvertTo-Json
      Update-MgDevice -DeviceId $Device.ObjectId -BodyParameter $Attributes 
      }
       Else { Write-Host ("Device {0} owned by unknown user {1}" -f $Device.DisplayName, $UserId ) }
  } 
$Results | Select-Object DeviceName,UserName | Export-Csv -Path $FullDataPath -NoType
Disconnect-MgGraph 