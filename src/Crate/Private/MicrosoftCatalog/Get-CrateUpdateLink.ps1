<#
.SYNOPSIS
    Retrieves download links for Microsoft Update Catalog updates

.DESCRIPTION
    This function retrieves the download links for a Microsoft Update by its GUID.
    It queries the Microsoft Update Catalog download dialog and extracts the file URLs.

.NOTES
    Name:        Get-CrateUpdateLink.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Get-CrateUpdateLink -Guid "12345678-1234-1234-1234-123456789012"
    Retrieves download links for the update with the specified GUID
#>
function Get-CrateUpdateLink {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String] $Guid
    )

    Write-CrateLog -Data "Getting update links for GUID: $Guid" -Level "Debug"

    $Post = @{size = 0; UpdateID = $Guid; UpdateIDInfo = $Guid} | ConvertTo-Json -Compress
    $Body = @{UpdateIDs = "[$Post]"}

    $Params = @{
        Uri             = "https://www.catalog.update.microsoft.com/DownloadDialog.aspx"
        Body            = $Body
        ContentType     = "application/x-www-form-urlencoded"
        UseBasicParsing = $true
    }

    try {
        Write-CrateLog -Data "Requesting download dialog from Microsoft Update Catalog" -Level "Debug"
        $DownloadDialog = Invoke-WebRequest @Params
        $Links = $DownloadDialog.Content -replace "www.download.windowsupdate", "download.windowsupdate"
        Write-CrateLog -Data "Successfully retrieved download dialog" -Level "Debug"
    }
    catch {
        Write-CrateLog -Data "Error retrieving download dialog: $_" -Level "Error"
        throw
    }

    $Regex = "downloadInformation\[0\]\.files\[\d+\]\.url\s*=\s*'([^']*kb(\d+)[^']*)'"
    $DownloadMatches = [regex]::Matches($Links, $Regex)

    if ($DownloadMatches.Count -eq 0) {
        Write-CrateLog -Data "No KB-numbered links found, trying fallback pattern" -Level "Debug"
        $RegexFallback = "downloadInformation\[0\]\.files\[0\]\.url\s*=\s*'([^']*)'"
        $DownloadMatches = [regex]::Matches($Links, $RegexFallback)
    }

    if ($DownloadMatches.Count -eq 0) {
        Write-CrateLog -Data "No download links found for GUID: $Guid" -Level "Warning"
        return $null
    }

    Write-CrateLog -Data "Found $($DownloadMatches.Count) download link(s)" -Level "Debug"

    $KbLinks = foreach ($Match in $DownloadMatches) {
        [PSCustomObject]@{
            URL = $Match.Groups[1].Value
            KB  = if ($Match.Groups.Count -gt 2 -and $Match.Groups[2].Success) { [int]$Match.Groups[2].Value } else { 0 }
        }
    }

    $result = $KbLinks | Sort-Object KB -Descending
    Write-CrateLog -Data "Returning $($result.Count) sorted download links" -Level "Debug"
    return $result
}