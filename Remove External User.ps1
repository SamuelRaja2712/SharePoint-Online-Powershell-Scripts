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
#Initializing Admin site URL
$AdminSiteURL="https://jsrsp-admin.sharepoint.com/"
#$cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName,$password)
$cred = New-Object System.Management.Automation.PSCredential($userName,$password)
$UserID = Read-Host "Enter External User Email Address"
Connect-SPOService $AdminSiteURL -Credential $cred

$user = Get-SPOExternalUser -Filter $UserID
Remove-SPOExternalUser -UniqueIDs @($user.UniqueId)
