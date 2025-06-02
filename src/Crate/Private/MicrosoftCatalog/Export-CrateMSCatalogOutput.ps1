<#
.SYNOPSIS
    Exports Microsoft Update Catalog search results to Excel format

.DESCRIPTION
    This function exports Microsoft Update Catalog update information to an Excel file.
    It uses the ImportExcel module to create formatted Excel worksheets with update data.

.NOTES
    Name:        Export-CrateMSCatalogOutput.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Export-CrateMSCatalogOutput -Update $updateObject -Destination "C:\Updates\report.xlsx"
    Exports update information to an Excel file
#>
function Export-CrateMSCatalogOutput {
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "ByObject"
        )]
        [Object] $Update,

        [Parameter(Mandatory = $true)]
        [string] $Destination,

        [string] $WorksheetName = "Updates"
    )

    Start-CrateOperation -Operation "Export MS Catalog to Excel"

    Write-CrateLog -Data "Checking for ImportExcel module" -Level "Debug"
    if (-not (Get-Module -Name ImportExcel -ListAvailable)) {
        try {
            Write-CrateLog -Data "Importing ImportExcel module" -Level "Debug"
            Import-Module ImportExcel -ErrorAction Stop
            Write-CrateLog -Data "ImportExcel module imported successfully" -Level "Debug"
        }
        catch {
            Write-CrateLog -Data "Unable to Import the Excel Module: $_" -Level "Error"
            Complete-CrateOperation -Operation "Export MS Catalog to Excel" -Success $false
            return
        }
    }

    Write-CrateProgress -Message "Preparing update data for export"

    if ($Update.Count -gt 1) {
        Write-CrateLog -Data "Multiple updates provided. Using only the first update." -Level "Debug"
        $Update = $Update | Select-Object -First 1
    }

    $data = [PSCustomObject]@{
        Title          = $Update.Title
        Products       = $Update.Products
        Classification = $Update.Classification
        LastUpdated    = $Update.LastUpdated.ToString('yyyy/MM/dd')
        Guid           = $Update.Guid
    }

    Write-CrateLog -Data "Prepared data for export: $($Update.Title)" -Level "Debug"

    $filePath = $Destination
    Write-CrateLog -Data "Exporting update information to $filePath" -Level "Info"

    if (Test-Path -Path $filePath) {
        Write-CrateLog -Data "File $filePath exists. Checking for duplicate entries." -Level "Debug"
        try {
            $existingData = Import-Excel -Path $filePath -WorksheetName $WorksheetName
            if ($existingData.Guid -contains $Update.Guid) {
                Write-CrateLog -Data "Update with GUID $($Update.Guid) already exists in $filePath" -Level "Warning"
                Complete-CrateOperation -Operation "Export MS Catalog to Excel" -Success $true
                return
            }
            Write-CrateLog -Data "Appending to existing Excel file" -Level "Debug"
            $data | Export-Excel -Path $filePath -WorksheetName $WorksheetName -Append -AutoSize -TableStyle Light1
            Write-CrateLog -Data "Successfully appended update to $filePath" -Level "Success"
        }
        catch {
            Write-CrateLog -Data "Error processing Excel file: $_" -Level "Error"
            Complete-CrateOperation -Operation "Export MS Catalog to Excel" -Success $false
            throw
        }
    }
    else {
        try {
            Write-CrateLog -Data "Creating new Excel file $filePath" -Level "Debug"
            $data | Export-Excel -Path $filePath -WorksheetName $WorksheetName -AutoSize -TableStyle Light1
            Write-CrateLog -Data "Successfully created new Excel file with update data" -Level "Success"
        }
        catch {
            Write-CrateLog -Data "Error creating Excel file: $_" -Level "Error"
            Complete-CrateOperation -Operation "Export MS Catalog to Excel" -Success $false
            throw
        }
    }

    Complete-CrateOperation -Operation "Export MS Catalog to Excel" -Success $true
}