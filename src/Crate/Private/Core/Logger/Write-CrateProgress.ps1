<#
.SYNOPSIS
    Writes a progress message to the Crate logging system

.DESCRIPTION
    Logs a progress message with special formatting in the Crate logging system.
    This function is designed to provide visual feedback during long-running
    operations with appropriate emoji indicators.

.NOTES
    Name:        Write-CrateProgress.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Message
    The progress message to log

.EXAMPLE
    Write-CrateProgress -Message "Loading configuration files"
    Logs a progress message with visual indicators
#>
function Write-CrateProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    process {
        if ($Script:CrateLogger) {
            $Script:CrateLogger.Progress($Message)
        }
        else {
            Write-CrateLog -Data "⏳ $Message" -Level "Info"
        }
    }
}
