<#
Update Cloudflare DNS with dynamic public IP
Exel 7/12/22
#>

# Grab current public IP
$currentIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

# Collect records and convert to dictionary object
$curl = curl -X GET "https://api.cloudflare.com/client/v4/zones/<YOUR_ZONE_ID>/dns_records?type=A" -H "X-Auth-Email: <YOUR_EMAIL>" -H "X-Auth-Key: <YOUR_API_KEY>" -H "Content-Type: application/json"
$zoneInfo = $curl | ConvertFrom-Json

# Filter for A only
$records = ($zoneInfo.result | Where-Object {$_.type -eq "A"}).name

# For each A record
foreach ($record in $records) {

  # Grab record ID
  $recordID = ($zoneInfo.result | Where-Object {$_.name -eq $record}).id

  # Set up PUT body
  $data = @{
      "type"="A"
      "name"="$record"
      "content"="$currentIP"
      "ttl"="86400"
      "proxied"=[bool]"true"
    }

  # Convert to JSON
  $data = $data | ConvertTo-Json

  # Update record
  Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/<YOUR_ZONE_ID>/dns_records/$recordID" -Method Put -Headers @{"X-Auth-Email"="<YOUR_EMAIL>";"X-Auth-Key"="<YOUR_API_KEY>";"Content-Type"="application/json"} -Body $data

}
