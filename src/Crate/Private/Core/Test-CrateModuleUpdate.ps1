<#
.SYNOPSIS
    Checks for available updates for the Crate module on PowerShell Gallery.

.DESCRIPTION
    This function checks PowerShell Gallery for newer versions of the Crate module
    and provides information about available updates.

.PARAMETER CurrentVersion
    The current version of the module to compare against.

.EXAMPLE
    Test-CrateModuleUpdate -CurrentVersion "25.5.26.1"
    Checks if a newer version than 25.5.26.1 is available.

.NOTES
    Name:        Test-CrateModuleUpdate.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate
#>
function Test-CrateModuleUpdate {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$CurrentVersion
    )

    process {
        try {
            Write-CrateLog -Data "Checking PowerShell Gallery for module updates..." -Level 'Info'

            $galleryModule = Find-Module -Name 'Crate' -ErrorAction SilentlyContinue

            if (-not $galleryModule) {
                Write-CrateLog -Data "Module not found on PowerShell Gallery" -Level 'Warning'
                return [PSCustomObject]@{
                    UpdateAvailable = $false
                    CurrentVersion  = $CurrentVersion
                    LatestVersion   = $null
                    UpdateCommand   = $null
                    Status          = "NotFound"
                }
            }

            $latestVersion = $galleryModule.Version.ToString()
            $updateAvailable = [version]$latestVersion -gt [version]$CurrentVersion

            if ($updateAvailable) {
                Write-CrateLog -Data "Update available: v$latestVersion (current: v$CurrentVersion)" -Level 'Warning'
                Write-CrateLog -Data "Run 'Update-Module -Name Crate' to update" -Level 'Info'
                $status = "UpdateAvailable"
            }
            else {
                Write-CrateLog -Data "Module is up to date (v$CurrentVersion)" -Level 'Success'
                $status = "UpToDate"
            }

            return [PSCustomObject]@{
                UpdateAvailable = $updateAvailable
                CurrentVersion  = $CurrentVersion
                LatestVersion   = $latestVersion
                UpdateCommand   = if ($updateAvailable) { "Update-Module -Name Crate" } else { $null }
                Status          = $status
            }
        }
        catch {
            Write-CrateLog -Data "Could not check for updates: $($_.Exception.Message)" -Level 'Warning'
            return [PSCustomObject]@{
                UpdateAvailable = $false
                CurrentVersion  = $CurrentVersion
                LatestVersion   = $null
                UpdateCommand   = $null
                Status          = "Error"
                ErrorMessage    = $_.Exception.Message
            }
        }
    }
}
