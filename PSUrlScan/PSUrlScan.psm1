function Get-UrlScanResults {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Uuid,

        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey = $env:URLSCAN_API_KEY
    )

    # header for req
    $headers = @{
        'API-Key' = $ApiKey
    }

    $retry = $true

    do {
        Write-Verbose "Getting results for UUID: $Uuid"
        
        try {
            $req = Invoke-WebRequest -Method Get -Uri "https://urlscan.io/api/v1/result/$Uuid" -Headers $headers
            if($req.StatusCode -eq '200') {

                Write-Verbose "Successful getting results"

                # stop the loop
                $retry = $false

                # get the content
                $content = $req.Content | ConvertFrom-Json

                # gen up the necessary data
                $res = [PSCustomObject][Ordered]@{
                    'Uuid' = $content.task.uuid
                    'Url' = $content.page.url
                    'Screenshot' = $content.task.screenshotURL
                    'Report' = $content.task.reportURL
                    'Malicious' = $content.verdicts.overall.malicious
                    'Score' = $content.verdicts.overall.score
                    'Scan' = @{
                        'Url' = $content.task.url
                        'Visibility' = $content.task.visibility
                        'Time' = $content.task.time
                    }
                    'NetInfo' = @{
                        'Ip' = $content.page.ip
                        'Ptr' = $content.page.ptr
                        'Asn' = $content.page.asn
                        'AsnName' = $content.page.asnname
                    }
                    'Netconns' = @{
                        'Domains' = $content.lists.domains
                        'Ips' = $content.lists.ips
                        'Urls' = $content.lists.urls
                    }
                    'Links' = $content.data.links
                }

                return $res
            }
            else {
                Write-Verbose "Status code: $($req.StatusCode) retrying in 10s"
            }
        }
        catch {
            Write-Verbose "Results not ready, trying again in 10 seconds..."
        }
        
        # urlscan recommends waiting about 10s per attempt
        Write-Verbose "Starting 10s sleep timer"
        Start-Sleep -Seconds 10

    } while($retry)
}

function Invoke-UrlScan {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Url,

        [ValidateNotNullOrEmpty()]
        [ValidateSet("public", "unlisted", "private")]
        [string]
        $Visibility = "public",

        [string]
        $UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36",

        [string]
        $HttpReferer = "",

        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey = $env:URLSCAN_API_KEY
    )

    # header for req
    $headers = @{
        'API-Key' = $ApiKey
        'Content-Type' = "application/json"
    }

    # body data for req
    $body = @{
        'url' = $Url
        'visibility' = $Visibility
        'referer' = $HttpReferer
        'customagent' = $UserAgent
    } | ConvertTo-Json

    $req = Invoke-WebRequest -Method Post -Uri "https://urlscan.io/api/v1/scan/" -Headers $headers -Body $body
    
    
    # statuscode 200 is a successful search
    if($req.StatusCode -eq '200') {
        $content = $req.Content | ConvertFrom-Json
        $res = [PSCustomObject][Ordered]@{
            'Uuid' = $content.uuid
            'Content' = $content
            'StatusCode' = $req.StatusCode
            'Rate-Limit-Scope' = $req.Headers["X-Rate-Limit-Scope"]
            'Rate-Limit-Action' = $req.Headers["X-Rate-Limit-Action"]
            'Rate-Limit-Window' = $req.Headers["X-Rate-Limit-Window"]
            'Rate-Limit-Limit' = $req.Headers["X-Rate-Limit-Limit"]
            'Rate-Limit-Remaining' = $req.Headers["X-Rate-Limit-Remaining"]
            'Rate-Limit-Reset' = $req.Headers["X-Rate-Limit-Reset"]
            'Rate-Limit-Reset-After' = $req.Headers["X-Rate-Limit-Reset-After"]
        }
    }
    else {
        # do something here
        $res = [PSCustomObject][Ordered]@{
            'Message' = "invalid request"
        }
    }

    # for now lets only give the uuid
    $res #.content | Select uuid
}

Export-ModuleMember -Function Invoke-UrlScan, Get-UrlScanResults