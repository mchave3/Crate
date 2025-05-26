<#
.SYNOPSIS
    Sets the silent mode for the Crate logging system

.DESCRIPTION
    Configures the Crate logger to operate in silent mode, which suppresses
    console output while maintaining log file writing. This is useful for
    UI compatibility and automated processes.

.NOTES
    Name:        Set-CrateLogSilent.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Silent
    Boolean value indicating whether to enable ($true) or disable ($false) silent mode

.EXAMPLE
    Set-CrateLogSilent -Silent $true
    Enables silent mode for the logger
#>
function Set-CrateLogSilent {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Silent
    )

    process {
        if ($PSCmdlet.ShouldProcess("Logger", "Set silent mode to $Silent")) {
            if ($Script:CrateLogger) {
                $Script:CrateLogger.SetSilentMode($Silent)
            }
        }
    }
}
