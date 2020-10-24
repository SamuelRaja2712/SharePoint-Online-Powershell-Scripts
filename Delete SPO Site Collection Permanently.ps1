$scriptdirectory = "D:\Powershell Scripts\"
Import-Module $($scriptdirectory + '\Reference\Microsoft.Online.SharePoint.PowerShell')
Add-Type -Path $($scriptdirectory + '\Reference\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll')
Add-Type -Path $($scriptdirectory + '\Reference\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll')
Add-Type -Path $($scriptdirectory + '\Reference\Microsoft.Online.SharePoint.PowerShell\Microsoft.Online.SharePoint.Client.Tenant.dll')
#$Credentials = Get-Credential
$credfile = Import-Csv $($scriptdirectory + "SharePoint\Credentials\credentials.csv")
#get username and password from credentials csv
$userName = $credfile[0].UserName
$password = ConvertTo-SecureString $credfile[0].Password
#Enter Site URL to delete permanently
$siteURL = Read-Host "Enter Site URL"
#Delete site from Active sites list in admin center
Remove-SPOSite -Identity $siteURL -Confirm
#Delete site from Deleted sites list in admin center
Remove-SPODeletedSite -Identity $siteURL -Confirm
