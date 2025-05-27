<#
.SYNOPSIS
    Retrieves the current version of the Crate module.

.DESCRIPTION
    This function retrieves the version of the Crate module from the module manifest,
    with fallback mechanisms for different scenarios.

.EXAMPLE
    Get-CrateVersion
    Returns the current version of the Crate module.

.NOTES
    Name:        Get-CrateVersion.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate
#>
function Get-CrateVersion {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    process {
        try {
            # Try to get version from loaded module first
            $loadedModule = Get-Module -Name 'Crate' | Select-Object -First 1
            if ($loadedModule) {
                return $loadedModule.Version.ToString()
            }

            # Try to get version from available modules
            $availableModule = Get-Module -Name 'Crate' -ListAvailable | Select-Object -First 1
            if ($availableModule) {
                return $availableModule.Version.ToString()
            }

            # Try to read directly from manifest file
            $manifestPath = Join-Path $PSScriptRoot "..\..\Crate.psd1"
            if (Test-Path $manifestPath) {
                $manifestData = Import-PowerShellDataFile -Path $manifestPath
                if ($manifestData.ModuleVersion) {
                    return $manifestData.ModuleVersion
                }
            }

            # Fallback version
            return "25.5.26.1"
        }
        catch {
            Write-CrateLog -Data "Error retrieving module version: $($_.Exception.Message)" -Level 'Warning'
            return "25.5.26.1"
        }
    }
}
