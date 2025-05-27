<#
.SYNOPSIS
    Starts a new operation in the Crate logging system

.DESCRIPTION
    Initiates tracking of a new operation in the Crate logging system.
    This function allows for structured operation tracking with
    automatic logging of the operation start.

.NOTES
    Name:        Start-CrateOperation.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Operation
    The name or description of the operation to start

.EXAMPLE
    Start-CrateOperation -Operation "Processing user data"
    Starts tracking of a new operation called "Processing user data"
#>
function Start-CrateOperation {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Operation
    )    process {
        if ($PSCmdlet.ShouldProcess($Operation, "Start operation")) {
            if ($Script:CrateLogger) {
                # Use the dedicated StartOperation method for consistency
                $Script:CrateLogger.StartOperation($Operation)
            }
            else {
                # Fallback to Write-CrateLog if logger not initialized
                Write-CrateLog -Data "Starting: $Operation" -Level "Info"
            }
        }
    }
}
