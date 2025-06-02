<#
.SYNOPSIS
    Downloads Microsoft Update Catalog updates to local storage

.DESCRIPTION
    This function downloads update files from the Microsoft Update Catalog.
    It can download individual updates or all available files for a given update GUID.

.NOTES
    Name:        Save-CrateMSCatalogUpdate.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Save-CrateMSCatalogUpdate -Guid "12345678-1234-1234-1234-123456789012" -Destination "C:\Updates"
    Downloads the update with the specified GUID to the destination folder
#>
function Save-CrateMSCatalogUpdate {
    param (
        [Parameter(
            Position = 0,
            ParameterSetName = "ByObject")]
        [Object] $Update,

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "ByGuid")]
        [String] $Guid,

        [Parameter(Position = 1)]
        [String] $Destination = (Get-Location).Path,

        [switch] $DownloadAll
    )

    Start-CrateOperation -Operation "Download MS Catalog Update"

    if ($Update) {
        $Guid = $Update.Guid | Select-Object -First 1
    }

    Write-CrateLog -Data "Getting download links for update with GUID: $Guid" -Level "Info"
    $Links = Get-CrateUpdateLink -Guid $Guid
    if (-not $Links) {
        Write-CrateLog -Data "No valid download links found for GUID '$Guid'" -Level "Warning"
        Complete-CrateOperation -Operation "Download MS Catalog Update" -Success $false
        return
    }

    # Check if destination directory exists and create it if needed
    if (-not (Test-Path -Path $Destination -PathType Container)) {
        try {
            Write-CrateLog -Data "Creating destination directory: $Destination" -Level "Debug"
            New-Item -Path $Destination -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-CrateLog -Data "Created destination directory: $Destination" -Level "Info"
        }
        catch {
            Write-CrateLog -Data "Failed to create destination directory '$Destination': $_" -Level "Error"
            Complete-CrateOperation -Operation "Download MS Catalog Update" -Success $false
            return
        }
    }

    $ProgressPreference = 'SilentlyContinue'
    $SuccessCount = 0
    $TotalCount = if ($DownloadAll) { $Links.Count } else { 1 }

    $message = "Found $($Links.Count) download links for GUID '$Guid'. $(if (-not $DownloadAll -and $Links.Count -gt 1) {"Only downloading the first file. Use -DownloadAll to download all files."})"
    Write-CrateLog -Data $message -Level "Info"

    Write-CrateProgress -Message "Preparing update download"
    $LinksToProcess = if ($DownloadAll) { $Links } else { $Links | Select-Object -First 1 }

    foreach ($Link in $LinksToProcess) {
        $url = $Link.URL
        $name = $url.Split('/')[-1]
        $cleanname = $name.Split('_')[0]

        # Determine extension based on URL or use .msu as default
        $extension = if ($url -match '\.(cab|exe|msi|msp|msu)$') {
            ".$($matches[1])"
        } else {
            ".msu"
        }

        $CleanOutFile = $cleanname + $extension

        $OutFile = Join-Path -Path $Destination -ChildPath $CleanOutFile

        if (Test-Path -Path $OutFile) {
            Write-CrateLog -Data "File already exists: $CleanOutFile. Skipping download." -Level "Warning"
            continue
        }

        try {
            Write-CrateProgress -Message "Downloading $CleanOutFile"
            Write-CrateLog -Data "Downloading $CleanOutFile from $url" -Level "Info"
            Set-CrateTempSecurityProtocol
            Invoke-WebRequest -Uri $url -OutFile $OutFile -ErrorAction Stop
            Set-CrateTempSecurityProtocol -ResetToDefault

            if (Test-Path -Path $OutFile) {
                Write-CrateLog -Data "Successfully downloaded file $CleanOutFile to $Destination" -Level "Success"
                $SuccessCount++
            }
            else {
                Write-CrateLog -Data "Downloading file $CleanOutFile failed" -Level "Error"
            }
        }
        catch {
            Write-CrateLog -Data "Error downloading $CleanOutFile : $_" -Level "Error"
        }
    }

    $result = "Download complete: $SuccessCount of $TotalCount files downloaded successfully."
    Write-CrateLog -Data $result -Level "Info"

    $success = ($SuccessCount -eq $TotalCount)
    Complete-CrateOperation -Operation "Download MS Catalog Update" -Success $success
}