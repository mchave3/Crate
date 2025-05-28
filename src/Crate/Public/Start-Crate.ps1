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
            if (-not (Test-IsAdministrator)) {
                if (Request-AdminRestart) {
                    Start-AdminSession
                    exit
                }
                else {
                    Write-OperationCancelled
                    return
                }
            }

            # Step 2: Check environment and launch accordingly
            if (Test-OptimalEnvironment) {
                Start-OptimalCrate
            }
            else {
                Start-OptimizedCrate
            }
        }
    }
}

#region Helper Functions

<#
.SYNOPSIS
    Tests if the current session is running with administrator privileges.
#>
function Test-IsAdministrator {
    $currentPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

<#
.SYNOPSIS
    Requests user confirmation to restart PowerShell as administrator.
#>
function Request-AdminRestart {
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
    return ([string]::IsNullOrWhiteSpace($choice) -or $choice -eq 'Y' -or $choice -eq 'y')
}

<#
.SYNOPSIS
    Starts a new PowerShell session with administrator privileges.
#>
function Start-AdminSession {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess("PowerShell session", "Start as Administrator")) {
        Write-Host ""
        Write-Host "     Restarting PowerShell as Administrator...               " -ForegroundColor Green
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host ""

        # Determine the module path
        $scriptPath = Get-CrateModulePath

        # Start new admin session
        Start-Process -FilePath "pwsh" -ArgumentList @(
            "-NoExit"
            "-Command"
            "Import-Module '$scriptPath'; Start-Crate"
        ) -Verb RunAs -WindowStyle Normal
    }
}

<#
.SYNOPSIS
    Gets the path to the Crate module.
#>
function Get-CrateModulePath {
    $scriptPath = $MyInvocation.MyCommand.Module.Path
    if ([string]::IsNullOrEmpty($scriptPath)) {
        $scriptPath = "C:\DEV\Crate\src\Artifacts\Crate.psd1"
    }
    return $scriptPath
}

<#
.SYNOPSIS
    Displays operation cancelled message.
#>
function Write-OperationCancelled {
    Write-Host ""
    Write-Host "     Operation cancelled by user.                          " -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

<#
.SYNOPSIS
    Tests if the current environment is optimal for running Crate.
#>
function Test-OptimalEnvironment {
    $isPowerShell7 = $PSVersionTable.PSVersion.Major -ge 7
    $currentSize = $Host.UI.RawUI.WindowSize
    $isOptimalSize = ($currentSize.Width -eq 100) -and ($currentSize.Height -eq 50)

    return ($isPowerShell7 -and $isOptimalSize)
}

<#
.SYNOPSIS
    Starts Crate in the current optimal environment.
#>
function Start-OptimalCrate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess("Crate CLI", "Start in current environment")) {
        Write-Host "Optimal environment detected (PowerShell 7+ with 100x50 console)" -ForegroundColor Green
        Start-CrateCLI
    }
}

<#
.SYNOPSIS
    Starts Crate in a new optimized PowerShell window.
#>
function Start-OptimizedCrate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess("Optimized PowerShell window", "Start new window")) {
        Write-Host "Opening a new optimized PowerShell window..." -ForegroundColor Yellow

        Start-Process -FilePath "pwsh" -ArgumentList @(
            "-NoExit"
            "-Command"
            "mode con: cols=100 lines=50; Import-Module 'C:\DEV\Crate\src\Artifacts\Crate.psd1'; Start-Crate"
        ) -WindowStyle Normal
    }
}

#endregion
