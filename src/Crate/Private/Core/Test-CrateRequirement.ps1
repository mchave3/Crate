<#
.SYNOPSIS
    Validates system requirements for Crate operations.

.DESCRIPTION
    Checks if the system meets all requirements for running Crate Windows ISO
    provisioning operations, including administrative privileges, PowerShell version,
    required tools, and disk space.

.PARAMETER AdminCheck
    Only check for administrative privileges.

.PARAMETER ToolsCheck
    Check for required external tools (DISM, etc.).

.PARAMETER DiskSpaceCheck
    Check available disk space in workspace.

.PARAMETER MinimumFreeSpaceGB
    Minimum free space required in GB. Defaults to 20GB.

.EXAMPLE
    Test-CrateRequirement
    Performs a complete system requirements check.

.EXAMPLE
    Test-CrateRequirement -AdminCheck
    Only checks if running with administrative privileges.

.NOTES
    Name:        Test-CrateRequirement.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Test-CrateRequirement {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$AdminCheck,

        [Parameter()]
        [switch]$ToolsCheck,

        [Parameter()]
        [switch]$DiskSpaceCheck,

        [Parameter()]
        [int]$MinimumFreeSpaceGB = 20
    )

    process {
        $allChecksPass = $true
        $results = @{}

        # Check administrative privileges
        if ($AdminCheck -or (-not $ToolsCheck -and -not $DiskSpaceCheck)) {
            Write-CrateLog -Data "Checking administrative privileges..." -Level 'Info'

            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

            $results.AdminPrivileges = $isAdmin

            if ($isAdmin) {
                Write-CrateLog -Data "✅ Running with administrative privileges" -Level 'Success'
            }
            else {
                Write-CrateLog -Data "❌ Administrative privileges required" -Level 'Error'
                $allChecksPass = $false
            }
        }

        # Check PowerShell version
        if (-not $AdminCheck -and -not $ToolsCheck -and -not $DiskSpaceCheck) {
            Write-CrateLog -Data "Checking PowerShell version..." -Level 'Info'

            $psVersion = $PSVersionTable.PSVersion
            $requiredVersion = [System.Version]"7.4.0"

            $results.PowerShellVersion = $psVersion

            if ($psVersion -ge $requiredVersion) {
                Write-CrateLog -Data "✅ PowerShell version $psVersion meets requirements (>= 7.4.0)" -Level 'Success'
            }
            else {
                Write-CrateLog -Data "❌ PowerShell version $psVersion is below required 7.4.0" -Level 'Error'
                $allChecksPass = $false
            }
        }

        # Check required tools
        if ($ToolsCheck -or (-not $AdminCheck -and -not $DiskSpaceCheck)) {
            Write-CrateLog -Data "Checking required tools..." -Level 'Info'

            $requiredTools = @('dism.exe', 'oscdimg.exe')
            $toolsAvailable = @{}

            foreach ($tool in $requiredTools) {
                $toolPath = Get-Command $tool -ErrorAction SilentlyContinue
                $toolsAvailable[$tool] = $null -ne $toolPath

                if ($toolsAvailable[$tool]) {
                    Write-CrateLog -Data "✅ Found $tool at: $($toolPath.Source)" -Level 'Success'
                }
                else {
                    Write-CrateLog -Data "❌ Required tool not found: $tool" -Level 'Error'
                    $allChecksPass = $false
                }
            }

            $results.RequiredTools = $toolsAvailable
        }

        # Check disk space
        if ($DiskSpaceCheck -or (-not $AdminCheck -and -not $ToolsCheck)) {
            Write-CrateLog -Data "Checking disk space..." -Level 'Info'

            $workspaceDrive = if ($Script:CrateWorkspace) {
                Split-Path $Script:CrateWorkspace -Qualifier
            }
            else {
                "C:"
            }

            try {
                $driveInfo = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $workspaceDrive }
                $freeSpaceGB = [math]::Round($driveInfo.FreeSpace / 1GB, 2)

                $results.FreeSpaceGB = $freeSpaceGB

                if ($freeSpaceGB -ge $MinimumFreeSpaceGB) {
                    Write-CrateLog -Data "✅ Sufficient disk space: ${freeSpaceGB}GB available (>= ${MinimumFreeSpaceGB}GB required)" -Level 'Success'
                }
                else {
                    Write-CrateLog -Data "❌ Insufficient disk space: ${freeSpaceGB}GB available (${MinimumFreeSpaceGB}GB required)" -Level 'Error'
                    $allChecksPass = $false
                }
            }
            catch {
                Write-CrateLog -Data "❌ Failed to check disk space: $($_.Exception.Message)" -Level 'Error'
                $allChecksPass = $false
            }
        }

        # Check Windows version
        if (-not $AdminCheck -and -not $ToolsCheck -and -not $DiskSpaceCheck) {
            Write-CrateLog -Data "Checking Windows version..." -Level 'Info'

            try {
                $osVersion = Get-CimInstance -ClassName Win32_OperatingSystem
                $results.WindowsVersion = $osVersion.Caption

                if ($osVersion.Caption -match "Windows 10|Windows 11|Windows Server") {
                    Write-CrateLog -Data "✅ Supported Windows version: $($osVersion.Caption)" -Level 'Success'
                }
                else {
                    Write-CrateLog -Data "⚠️  Unsupported Windows version: $($osVersion.Caption)" -Level 'Warning'
                }
            }
            catch {
                Write-CrateLog -Data "❌ Failed to check Windows version: $($_.Exception.Message)" -Level 'Error'
            }
        }

        $results.AllChecksPass = $allChecksPass

        if ($allChecksPass) {
            Write-CrateLog -Data "✅ All system requirements validated successfully" -Level 'Success'
        }
        else {
            Write-CrateLog -Data "❌ Some system requirements are not met" -Level 'Error'
        }

        return $allChecksPass
    }
}
