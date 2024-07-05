#Grabs DKIM, DMARC, and SPF and outputs to a file.
 $filepath = Read-Host -prompt 'Input complete filepath to list of domains.'
 Write-Host "Scraped domains will appear as they are completed."
 $EndFilePath = [environment]::getfolderpath("mydocuments")
Get-Content $filepath | ForEach-Object {
	Write-Host($_)
	$domain = $_.Trim()
	$selectors = 'selector1','selector2','google','everlytickey1','everlytickey2','eversrv','k1','mxvault','dkim'
	$SPFRecord = (Resolve-DnsName $domain -type txt -ErrorAction SilentlyContinue| ? {$_.strings -match 'spf'}).strings
	$dkimcname = ($selectors | ForEach-Object { $selector = $_; Resolve-DnsName -Type CNAME -Name "$($selector)._domainkey.$($domain)" -ErrorAction SilentlyContinue | Select NameHost}).NameHost
	$dkimtxt = ($selectors | ForEach-Object { $selector = $_; Resolve-DnsName -Type TXT -Name "$($selector)._domainkey.$($domain)" -ErrorAction SilentlyContinue | Select Strings}).Strings
	$dmarcrecord = (Resolve-DNSName -name ("_dmarc."+$($domain)) -Type TXT -erroraction SilentlyContinue | Select strings).strings
	
	Add-Content -Path "$EndFilePath\Info_Scraper_Report.txt" -Value $domain, $SPFRecord, $dkimcname, $dkimcname, $dmarcrecord
}
Write-Host "Report has been saved to your default documents folder. Filepath: $EndFilePath\Info_Scraper_Report.txt"