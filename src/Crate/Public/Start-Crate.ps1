<#
.SYNOPSIS
    Starts the Crate provisioning tool in a new PowerShell window.

.DESCRIPTION
    This script launches the Crate provisioning tool in a new PowerShell window with
    a specified console mode for better visibility. It imports the Crate module and
    starts the interactive CLI interface. The function performs several validation checks:
    - Administrator privileges verification
    - PowerShell version compatibility (7+)
    - Console size optimization (100x50)

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
    Starts the Crate provisioning tool with automatic environment optimization.
#>
function Start-Crate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        Clear-Host
    }

    process {
        if ($PSCmdlet.ShouldProcess("Crate provisioning tool", "Start")) {

            # Step 1: Validate administrator privileges
            $currentPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
            $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

            if (-not $isAdmin) {
                # Request admin restart
                Write-Host ""
                Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                Write-Host "                  /!\ ADMINISTRATOR REQUIRED                   " -ForegroundColor Yellow
                Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "      Crate requires administrator privileges to function      " -ForegroundColor White
                Write-Host "          properly and manage system configurations.           " -ForegroundColor White
                Write-Host ""
                Write-Host "     Do you want to restart PowerShell as Administrator ?      " -ForegroundColor Cyan
                Write-Host ""
                Write-Host " [Y] Yes  [N] No  (default is 'Y') : " -ForegroundColor White -NoNewline

                $choice = Read-Host
                $shouldRestart = ([string]::IsNullOrWhiteSpace($choice) -or $choice -eq 'Y' -or $choice -eq 'y')

                if ($shouldRestart) {
                    if ($PSCmdlet.ShouldProcess("PowerShell session", "Start as Administrator")) {
                        Write-Host ""
                        Write-Host "     Restarting PowerShell as Administrator...               " -ForegroundColor Green
                        Write-Host ""
                        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                        Write-Host ""

                        # Determine the module path
                        $scriptPath = $MyInvocation.MyCommand.Module.Path
                        if ([string]::IsNullOrEmpty($scriptPath)) {
                            $scriptPath = "C:\DEV\Crate\src\Artifacts\Crate.psd1"
                        }

                        # Start new admin session
                        Start-Process -FilePath "pwsh" -ArgumentList @(
                            "-NoExit"
                            "-Command"
                            "Import-Module '$scriptPath'; Start-Crate"
                        ) -Verb RunAs -WindowStyle Normal
                    }
                    exit
                }
                else {
                    # Operation cancelled
                    Write-Host ""
                    Write-Host "     Operation cancelled by user.                          " -ForegroundColor Red
                    Write-Host ""
                    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
                    Write-Host ""
                    return
                }
            }

            # Step 2: Check environment and launch accordingly
            $isPowerShell7 = $PSVersionTable.PSVersion.Major -ge 7
            $currentSize = $Host.UI.RawUI.WindowSize
            $isOptimalSize = ($currentSize.Width -eq 100) -and ($currentSize.Height -eq 50)
            $isOptimalEnvironment = ($isPowerShell7 -and $isOptimalSize)

            if ($isOptimalEnvironment) {
                # Start in current optimal environment
                if ($PSCmdlet.ShouldProcess("Crate CLI", "Start in current environment")) {
                    Write-Host "Optimal environment detected (PowerShell 7+ with 100x50 console)" -ForegroundColor Green
                    Start-CrateCLI
                }
            }
            else {
                # Start in new optimized window
                if ($PSCmdlet.ShouldProcess("Optimized PowerShell window", "Start new window")) {
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
}
