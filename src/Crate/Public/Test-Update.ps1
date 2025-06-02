function Test-Update {
    <#
    .SYNOPSIS
        Test function to demonstrate MSCatalog update search functionality

    .DESCRIPTION
        This function demonstrates the usage of Get-CrateMSCatalogUpdate by searching for x64 updates

    .EXAMPLE
        Test-Update
        Runs a test search for x64 updates
    #>
    [CmdletBinding()]
    param()

    # Example search for Windows 11 x64 updates
    Get-CrateMSCatalogUpdate -OperatingSystem "Windows 10" -Version "22H2" -UpdateType "Cumulative Updates" -Architecture "x64" -LastDays 30 | Out-GridView
}