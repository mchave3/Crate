<#
.SYNOPSIS
    Resets the Crate logging system

.DESCRIPTION
    Completely resets the Crate logger instance, clearing all in-memory
    data and releasing resources. This is useful for testing scenarios
    or when reinitializing the logging system is required.

.NOTES
    Name:        Reset-CrateLogger.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Reset-CrateLogger
    Resets the Crate logger instance
#>
function Reset-CrateLogger {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess("Logger", "Reset Crate logger")) {
            $Script:CrateLogger = $null
        }
    }
}
