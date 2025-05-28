<#
.SYNOPSIS
    Starts the Crate provisioning tool in a new PowerShell window.

.DESCRIPTION
    This script launches the Crate provisioning tool in a new PowerShell window with
    a specified console mode for better visibility. It imports the Crate module and
    starts the interactive CLI interface.

.NOTES
    Name:        Start-Crate.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.28.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Start-Crate
#>
function Start-Crate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin{
        Clear-Host
    }

    process {
        if ($PSCmdlet.ShouldProcess("Crate provisioning tool", "Start")) {
            # Check if running as administrator
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $isAdmin) {
                Write-Host ""
                Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                Write-Host "                  /!\ ADMINISTRATOR REQUIRED                   " -ForegroundColor Yellow
                Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "      Crate requires administrator privileges to function      " -ForegroundColor White
                Write-Host "          properly and manage system configurations.           " -ForegroundColor White
                Write-Host ""
                Write-Host "    Please restart PowerShell as Administrator and try again.  " -ForegroundColor Cyan
                Write-Host ""
                Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                Write-Host ""
                return
            }

            # Check if we are running PowerShell 7+
            $isPowerShell7 = $PSVersionTable.PSVersion.Major -ge 7

            # Check current console size
            $currentSize = $Host.UI.RawUI.WindowSize
            $isOptimalSize = ($currentSize.Width -eq 100) -and ($currentSize.Height -eq 50)

            if ($isPowerShell7 -and $isOptimalSize) {
                # Optimal conditions: launch Start-CrateCLI directly
                Write-Host "Optimal environment detected (PowerShell 7+ with 100x50 console)" -ForegroundColor Green
                Start-CrateCLI
            }
            else {
                # Launch a new window with optimal parameters
                Write-Host "Opening a new optimized PowerShell window..." -ForegroundColor Yellow
                Start-Process -FilePath "pwsh" -ArgumentList @(
                    "-NoExit"
                    "-Command"
                    "mode con: cols=100 lines=50; Import-Module 'C:\DEV\Crate\src\Artifacts\Crate.psd1'; Start-Crate"
                ) -WindowStyle Normal
            }
        }
    }
}
