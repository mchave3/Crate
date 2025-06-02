<#
.SYNOPSIS
    Converts a date string from Microsoft Update Catalog format to DateTime

.DESCRIPTION
    This function parses date strings from the Microsoft Update Catalog format (MM/dd/yyyy)
    and converts them to PowerShell DateTime objects.

.NOTES
    Name:        ConvertFrom-CrateDateString.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    ConvertFrom-CrateDateString -DateString "12/31/2024"
    Converts the date string to a DateTime object
#>
function ConvertFrom-CrateDateString {
    param (
        [String] $DateString
    )

    try {
        Write-CrateLog -Data "Converting date string: $DateString" -Level "Debug"
        $Array = $DateString.Split("/")

        if ($Array.Count -ne 3) {
            Write-CrateLog -Data "Invalid date format: $DateString. Expected MM/DD/YYYY format." -Level "Warning"
            return $null
        }

        $date = Get-Date -Year $Array[2] -Month $Array[0] -Day $Array[1] -ErrorAction Stop
        Write-CrateLog -Data "Date conversion successful: $date" -Level "Debug"
        return $date
    }
    catch {
        Write-CrateLog -Data "Error converting date string '$DateString': $_" -Level "Error"
        throw
    }
}