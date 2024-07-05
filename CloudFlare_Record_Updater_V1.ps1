#Adds an SPF record to Cloudflare when given a domain, a type of file, and the contents of the record.

<#Have the user input the type of record they are changing, 
who they are doing it to, and the contents of the change.#>
$Domain = Read-Host -prompt "Input your desired domain."
$Type = Read-Host -prompt "Input your desired type"
$String = Read-Host -prompt "Input your desired record"

#Mousekatool section (tools that wil help us later lol)
global:$APIToken = "your-api-key"
global:$AccountEmail = "your-account-email"
global:$APIURI = 'https://api.cloudflare.com/client/v4'
#Build required header for authentication
global:$Headers = @{
		'X-Auth-Key'   = $Token
        'X-Auth-Email' = $EMail
}
#Where the magic happens!
Function Get-CFZones {
    #Grab parameters for headers.
	Param (
        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [string]$EMail
    )
    #API call and formatting of returned data.
	$Zones = Invoke-RestMethod -Headers $Headers -Uri $APIURI/zones
    $ZoneOutput = @()
    Foreach ($zone In $Zones.result) {
        $ZoneOutput += [PSCustomObject]@{
            "Id"           = $Zone.id
            "Name"         = $Zone.name
            "Status"       = $Zone.status
            "Paused"       = $Zone.paused
            "Name Servers" = $Zone.name_servers
        }
    }
    Write-Output $ZoneOutput
}
#Using the function below to grab the ZoneID number of the Domain given to us by the user.
$ZoneID = (Get-CFZones -Token $APIToken -EMail $AccountEmail | where Name -eq $Domain).Id3

$Body = @{
	type = "TXT"
	name = $Domain
	content = $String
}
$Json_Body = $Body | ConvertTo-Json

#Now for the final part. Making a POST call to add a new spf record.
Function Append-Record {
	Param (
		[Parameter(Mandatory = $true)]
        [string]$Zone
		
		[Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [string]$EMail
	)
	Invoke-RestMethod -URI $APIURI/zones/$Zone/dns_records `
	-Method 'POST' `
	-ContentType "application/json" `
	-Headers $Headers `
	-Body $Json_Body
}
Append-Record -Zone $ZoneID -Token $APIToken -EMail $AccountEmail 