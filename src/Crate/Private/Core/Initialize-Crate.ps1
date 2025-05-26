<#
.SYNOPSIS
    Initializes the Crate Windows ISO provisioning environment.

.DESCRIPTION
    Sets up the workspace, validates administrative privileges, checks requirements,
    and prepares the environment for ISO provisioning operations.

.PARAMETER WorkspacePath
    The path where Crate will store its working files. Defaults to C:\ProgramData\Crate.

.PARAMETER Force
    Forces re-initialization even if already initialized.

.EXAMPLE
    Initialize-Crate
    Initializes Crate with default settings.

.EXAMPLE
    Initialize-Crate -WorkspacePath "D:\CrateWorkspace" -Force
    Initializes Crate with custom workspace and forces re-initialization.

.NOTES
    Name:        Initialize-Crate.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
    Requires administrative privileges.
    Creates workspace structure if it doesn't exist.

.LINK
    https://github.com/mchave3/Crate
#>
function Initialize-Crate {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$WorkspacePath = 'C:\ProgramData\Crate',

        [Parameter()]
        [switch]$Force
    )

    begin {
        Write-CrateLog -Data "Starting Crate initialization..." -Level 'Info'
    }

    process {
        $Error.Clear()

        try {
            # Check if running as administrator
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $isAdmin) {
                throw "Crate requires administrative privileges. Please run as administrator."
            }

            # Create workspace structure
            $workspaceStructure = @(
                'Config',
                'Config\profiles',
                'Config\cache',
                'Workspace',
                'Workspace\ISO',
                'Workspace\WIM',
                'Workspace\Temp',
                'Downloads',
                'Downloads\Updates',
                'Downloads\LanguagePacks',
                'Logs',
                'Backup'
            )

            foreach ($folder in $workspaceStructure) {
                $fullPath = Join-Path $WorkspacePath $folder
                if (-not (Test-Path $fullPath)) {
                    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
                    Write-CrateLog -Data "Created workspace folder: $fullPath" -Level 'Info'
                }
            }

            # Initialize configuration
            $configPath = Join-Path $WorkspacePath 'Config\settings.json'
            if (-not (Test-Path $configPath) -or $Force) {
                $defaultConfig = @{
                    WorkspacePath = $WorkspacePath
                    LogLevel = 'Info'
                    MaxLogFiles = 10
                    AutoCleanup = $true
                    BackupEnabled = $true
                    DefaultProfile = 'Default'
                    CreatedDate = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                    Version = '25.5.26.1'
                } | ConvertTo-Json -Depth 3

                $defaultConfig | Out-File -FilePath $configPath -Encoding UTF8
                Write-CrateLog -Data "Created default configuration: $configPath" -Level 'Info'
            }

            # Set global variables
            $global:CrateWorkspace = $WorkspacePath
            $global:CrateInitialized = $true

            Write-CrateLog -Data "Crate initialization completed successfully" -Level 'Info'
            Write-Host "✅ Crate initialized successfully!" -ForegroundColor Green
            Write-Host "📂 Workspace: $WorkspacePath" -ForegroundColor Cyan

            return $true
        }
        catch {
            Write-CrateLog -Data "Initialization failed: $($_.Exception.Message)" -Level 'Error'
            Write-Host "❌ Initialization failed: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}
