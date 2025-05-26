<#
.SYNOPSIS
    Completes an operation in the Crate logging system

.DESCRIPTION
    Marks an operation as completed in the Crate logging system.
    This function allows for structured operation tracking with
    automatic logging of the operation completion status.

.NOTES
    Name:        Complete-CrateOperation.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Operation
    The name or description of the operation to complete

.PARAMETER Success
    Indicates whether the operation completed successfully. Default is $true

.EXAMPLE
    Complete-CrateOperation -Operation "Processing user data" -Success $true
    Marks the "Processing user data" operation as successfully completed
#>
function Complete-CrateOperation {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Operation,

        [Parameter()]
        [bool]$Success = $true
    )

    process {
        if ($Script:CrateLogger) {
            $Script:CrateLogger.EndOperation($Operation, $Success)
        }
        else {
            $level = if ($Success) { "Success" } else { "Error" }
            $emoji = if ($Success) { "✅" } else { "❌" }
            Write-CrateLog -Data "$emoji Completed: $Operation" -Level $level
        }
    }
}
