# PSUrlScan
PSUrlScan is a PowerShell module that provides an easy-to-use PowerShell interface for the URLScan.io API. It lets users initiate a URL scan and retrieve the results right from the PowerShell command line.

## Installation
To install this module, you can use the Install-Module command as follows:

PowerShell
```
Install-Module ./PSUrlScan/PSUrlScan.psm1
```

## Prerequisites
This module uses the URLScan.io API, so you will need a URLScan.io API key to use it. You can obtain one from the URLScan.io website.

Once you have an API key, you can store it in the `URLSCAN_API_KEY` environment variable on your system. This will allow the `Get-UrlScanResults` and `Invoke-UrlScan` functions to use it by default.

## Usage
This module provides two functions:

*Invoke-UrlScan*
* This function initiates a URL scan on URLScan.io.

Example
```
Invoke-UrlScan -Url "http://example.com" -Visibility "public" -UserAgent "YourUserAgent" -HttpReferer "http://referrer.com" -ApiKey "your_api_key"
```

Parameters
```
-Url (Mandatory): The URL to scan.
-Visibility: The visibility setting for the scan. This can be "public", "unlisted", or "private". The default is "private".
-UserAgent: The user agent to use for the scan. The default is a standard user agent string.
-HttpReferer: The HTTP referer to use for the scan. This is optional.
-ApiKey: Your URLScan.io API key. This is optional if you have set the URLSCAN_API_KEY environment variable.
```

*Get-UrlScanResults*
* This function retrieves the results of a URL scan from URLScan.io.

Example
```
Get-UrlScanResults -Uuid "scan_uuid" -ApiKey "your_api_key"
```

Parameters
```
-Uuid (Mandatory): The UUID of the scan to retrieve results for.
-ApiKey: Your URLScan.io API key. This is optional if you have set the URLSCAN_API_KEY environment variable.
```

## License
This project is licensed under the terms of the Unlicense license.