 <#This script looks at if a domains SPF is connected to Microsoft Exchange by checking
 if the SPF record has "includes: spf.protection.outlook.com" in it#>
 $filepath = Read-Host -prompt 'Input complete filepath to list of domains.'
 Write-Host "Domains will be listed as they are scanned."
 $EndFilePath = [environment]::getfolderpath("mydocuments")
Get-Content "$filepath" | ForEach-Object {
	$domain = $_
	Add-Content -path $EndFilePath\SPF_Security_Report.txt -value $domain -NoNewLine
	Write-Host($domain)
	$SPFRecord = (Resolve-DnsName $domain -type txt -ErrorAction SilentlyContinue| ? {$_.strings -match 'spf'}).strings
		
	if ($SPFRecord -like "*spf.protection.outlook.com*") {
		$SecVal = '1'
	} else {
		$SecVal = '0' 
	}
Add-Content -path $EndFilePath\SPF_Security_Report.txt -value "$SecVal"
}	
Write-Host "Report has been saved to your default documents folder. 1 is secure, 0 is not."
Write-Host "Filepath: $EndFilePath\SPF_Security_Report.txt"
