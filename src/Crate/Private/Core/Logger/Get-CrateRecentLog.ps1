<#
.SYNOPSIS
    Retrieves recent log entries from the Crate logging system

.DESCRIPTION
    Returns a specified number of recent log entries from the in-memory
    buffer of the Crate logging system. This is useful for debugging
    and reviewing recent activity without accessing log files directly.

.NOTES
    Name:        Get-CrateRecentLog.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Count
    The number of recent log entries to retrieve. Default is 20

.EXAMPLE
    Get-CrateRecentLog -Count 10
    Returns the 10 most recent log entries
#>
function Get-CrateRecentLog {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter()]
        [int]$Count = 20
    )

    process {
        if ($Script:CrateLogger) {
            return $Script:CrateLogger.GetRecentLogs($Count)
        }
        else {
            return @()
        }
    }
}
