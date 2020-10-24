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
#list of sharepoint sites with template ID
$templateCSV = Import-Csv $($scriptdirectory + "SharePoint\SiteTemplate.csv")
#SharePoint site where site creation request is created
$SiteURL="https://jsrsp.sharepoint.com//sites/spsite"
#creating SharePoint Online credentials
$cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName,$password)
#creating Context
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$ctx.Credentials = $cred
$web = $ctx.Web
$ctx.Load($web)
$ctx.ExecuteQuery()
#Getting site creation list
$list = $web.Lists.GetByTitle("Site Creation")
#Querying items only when status is equal to Submitted
$query = New-Object Microsoft.SharePoint.Client.CamlQuery
$query.ViewXml = "@
<View Scope='RecursiveAll'>
    <Query>
        <Where>
            <Eq>
                <FieldRef Name='Status' />
                <Value Type='Choice'>Submitted</Value>
            </Eq>
        </Where>
    </Query>
</View>
"
$queriedValue = $list.GetItems($query)
$ctx.Load($queriedValue)
$ctx.ExecuteQuery()
#Looping each item to create the site
foreach($item in $queriedValue){
    #Updating site creation status to "In-Progress"
    $item["Status"] = "In-Progress"
    $item.Update()
    $ctx.ExecuteQuery()
    #Getting required details from Site Creation List to create new SPO site
    $siteCreationURL = $item["Site_x0020_URL"]
    $PrimaryOwner = $item["Primary_x0020_Owner"].Email
    $SecondaryOwner = $item["Secondary_x0020_Owner"].Email
    $template = $item["Template"]
    $siteTitle = $item["Title"]
    #Looping template object to get site template ID
    foreach($templateval in $templateCSV){
        if($templateval.TemplateName -eq $template){
            $SiteCreationtemplate = $templateval.TemplateId
        }
    }   
    try{ 
        #Creating new SPO site
        New-SPOSite -Url $siteCreationURL -Owner $PrimaryOwner -StorageQuota 1000 -CompatibilityLevel 15 -LocaleID 1033 -ResourceQuota 50 -Template $SiteCreationtemplate -TimeZoneId 13 -Title $siteTitle
        #Sleep for 25 seconds
        Start-Sleep -s 25
        #Checked secondary owner is added to request and add the secondary owner as site collection admin
        if($SecondaryOwner -ne $null){
            Set-SPOUser -Site $siteCreationURL -LoginName $SecondaryOwner -IsSiteCollectionAdmin $true            
        }
        Write-Host "Site has been created successfully" $siteCreationURL
        #Updating site creation status to "Completed"
        $item["Status"] = "Completed"
        $item.Update()
        $ctx.ExecuteQuery()
    }
    catch{
        Write-Host "Error in Site Creation" $siteCreationURL $($_.Exception.Message)
        #Check if error contains site already exists
        if($_.Exception.Message -like "*A site already exists at url*")
        {
            $ErrorMsg = "Site Already Exists"
        }
        else{
            $ErrorMsg = "Error"
        }
        #Updating Status according to error
        $item["Status"] = $ErrorMsg
        $item.Update()
        $ctx.ExecuteQuery()
    }    
}