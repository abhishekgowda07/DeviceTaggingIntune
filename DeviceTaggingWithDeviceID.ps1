Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Scopes "Directory.AccessAsUser.All"
Select-MgProfile Beta
Connect-AzureAD

$Results = @()
$Currentdt = Get-Date -Format "yyyyMMdd_HH_mm"
$DataPath = "C:\temp\Devices_Tagged_" + "$Currentdt.csv"
$FullDataPath = $DataPath
$Dev=Import-Csv -Path C:\Temp\Book1.csv  #CSV path
$Devices1=$Dev.DeviceId
$Devices= ForEach ($ids in $Devices1) {
Get-MgDevice -Filter "DeviceId eq '$($ids)'" -All
}

ForEach ($Device in $Devices) {
  $user=Get-AzureADDeviceRegisteredUser -ObjectId $Device.Id
  $UserId=$user.ObjectId
  if($UserId){
  [array]$mgu=(Get-MgUser -UserId $UserId).OnPremisesExtensionAttributes.ExtensionAttribute13}
  If ($user) {
  $ext=$mgu[0].ToString()
   $Properties = @{
   DeviceName=$Device.DisplayName
   UserName=$user.DisplayName
   }
   $Results += New-Object psobject -Property $properties
         Write-Host ("Device {0} owned by {1}" -f $Device.DisplayName, $user.DisplayName)
            $Attributes = @{
           "extensionAttributes" = @{
           "extensionAttribute13" = $ext }
         }  | ConvertTo-Json
      Update-MgDevice -DeviceId $Device.Id -BodyParameter $Attributes
      }
       Else { Write-Host ("Device {0} owned by unknown user {1}" -f $Device.DisplayName, $UserId ) }
  }
$Results | Select-Object DeviceName,UserName | Export-Csv -Path $FullDataPath -NoType
Disconnect-MgGraph