$scriptdirectory = "D:\Powershell Scripts\SharePoint\Credentials"
$credentialsFile = "$scriptdirectory\credentials.csv"
if(!(Test-Path $credentialsFile)){
    Write-Host "Credentials file is not available in this folder. Create new Credentials File" -ForegroundColor White -BackgroundColor Red
    $c = @()
    Add-Content -Path $credentialsFile -Value '"UserName","Password"'
    Write-Host "Please enter credentails to SharePoint site" -ForegroundColor Yellow
    Start-Sleep 1
    $cred = $Host.UI.PromptForCredential("SharePoint site credentials","To connect to sites","","")
    $password = ConvertFrom-SecureString $cred.Password
    $row = "$($cred.UserName),$password"
    $C += @($row)
    Start-Sleep 1

    $c | foreach {Add-Content -Path $credentialsFile -Value $_}
    Write-Host "Credential file is created" -ForegroundColor White -BackgroundColor Blue
    Start-Sleep 1
}
else{
    Write-Host "Credential file is already exist" -ForegroundColor Red -BackgroundColor White
    Start-Sleep 3
}