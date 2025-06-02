<#
.SYNOPSIS
    Temporarily modifies the .NET security protocol for web requests

.DESCRIPTION
    This function temporarily sets the .NET security protocol to include TLS 1.1 and 1.2
    for compatibility with Microsoft Update Catalog requests. It can also reset to the original protocol.

.NOTES
    Name:        Set-CrateTempSecurityProtocol.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Set-CrateTempSecurityProtocol
    Sets the security protocol to include TLS 1.1 and 1.2

.EXAMPLE
    Set-CrateTempSecurityProtocol -ResetToDefault
    Resets the security protocol to its original value
#>
function Set-CrateTempSecurityProtocol {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [switch] $ResetToDefault
    )

    try {
        if (($null -ne $Script:MSCatalogSecProt) -and $ResetToDefault) {
            if ($PSCmdlet.ShouldProcess("Reset .NET security protocol to original settings")) {
                Write-CrateLog -Data "Resetting security protocol to original settings" -Level "Debug"
                [Net.ServicePointManager]::SecurityProtocol = $Script:MSCatalogSecProt
                Write-CrateLog -Data "Security protocol reset to: $($Script:MSCatalogSecProt)" -Level "Debug"
            }
        } else {
            if ($null -eq $Script:MSCatalogSecProt) {
                $Script:MSCatalogSecProt = [Net.ServicePointManager]::SecurityProtocol
                Write-CrateLog -Data "Original security protocol stored: $($Script:MSCatalogSecProt)" -Level "Debug"
            }

            $Tls11 = [System.Net.SecurityProtocolType]::Tls11
            $Tls12 = [System.Net.SecurityProtocolType]::Tls12
            $CurrentProtocol = [Net.ServicePointManager]::SecurityProtocol
            $NewProtocol = $CurrentProtocol -bor $Tls11 -bor $Tls12

            if ($PSCmdlet.ShouldProcess("Set .NET security protocol to include TLS 1.1 and 1.2")) {
                Write-CrateLog -Data "Setting security protocol to include TLS 1.1 and 1.2" -Level "Debug"
                [Net.ServicePointManager]::SecurityProtocol = $NewProtocol
                Write-CrateLog -Data "Security protocol set to: $([Net.ServicePointManager]::SecurityProtocol)" -Level "Debug"
            }
        }
    }
    catch {
        Write-CrateLog -Data "Error setting security protocol: $_" -Level "Error"
        throw
    }
}