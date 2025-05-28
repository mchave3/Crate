<#
.SYNOPSIS
    Initializes the Crate Windows ISO provisioning environment.

.DESCRIPTION
    This function sets up the Crate environment by creating necessary directories,
    initializing configuration files, and ensuring that the user has administrative privileges.
    It also sets global variables for the Crate workspace and logs the initialization process.

.PARAMETER WorkspacePath
    The path where Crate will store its working files. Defaults to C:\ProgramData\Crate.

.PARAMETER Force
    Forces re-initialization even if already initialized.

.EXAMPLE
    Initialize-Crate
    Initializes Crate with default settings.

.EXAMPLE
    Initialize-Crate -WorkspacePath 'D:\CrateWorkspace' -Force
    Initializes Crate with a custom workspace path and forces re-initialization.

.NOTES
    Name:        Initialize-Crate.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate
#>
function Initialize-Crate {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter()]
        [string]$WorkspacePath = 'C:\ProgramData\Crate',

        [Parameter()]
        [switch]$Force
    )

    begin {
        #region Logger Initialization (Priority 1)
        # Initialize logger first to capture all subsequent initialization logs

        # Ensure logs directory exists before creating logger
        $logsPath = Join-Path $WorkspacePath 'Logs'
        if (-not (Test-Path $logsPath)) {
            try {
                New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
            }
            catch {
                throw "Error creating logs directory: $($_.Exception.Message)"
            }
        }

        # Create logger instance
        $logFile = Join-Path $logsPath "Crate.log"
        try {
            $Script:CrateLogger = [CrateLogger]::new($logFile)
        }
        catch {
            throw "Error creating logger: $($_.Exception.Message)"
        }
        #endregion

        #region Welcome Banner and Version Information (Priority 2)
        # Clear screen and show welcome banner
        Clear-Host

        # Get module version dynamically
        try {
            # Try to get version from loaded module first
            $loadedModule = Get-Module -Name 'Crate' | Select-Object -First 1
            if ($loadedModule) {
                $currentVersion = $loadedModule.Version.ToString()
            }
            else {
                # Try to get version from available modules
                $availableModule = Get-Module -Name 'Crate' -ListAvailable | Select-Object -First 1
                if ($availableModule) {
                    $currentVersion = $availableModule.Version.ToString()
                }
                else {
                    # Try to read directly from manifest file
                    $manifestPath = Join-Path $PSScriptRoot "..\..\Crate.psd1"
                    if (Test-Path $manifestPath) {
                        $manifestData = Import-PowerShellDataFile -Path $manifestPath
                        if ($manifestData.ModuleVersion) {
                            $currentVersion = $manifestData.ModuleVersion
                        }
                        else {
                            $currentVersion = "25.5.26.1"
                        }
                    }
                    else {
                        $currentVersion = "25.5.26.1"
                    }
                }
            }
        }
        catch {
            $currentVersion = "25.5.26.1"  # Fallback version
        }

        # Log the initialization start
        Write-CrateLog -Data "====================================================" -Level 'Info'
        Write-CrateLog -Data "    >>> STEP 1/8: INITIALIZATION START <<<" -Level 'Info'
        Write-CrateLog -Data "====================================================" -Level 'Info'
        Write-CrateLog -Data "Crate - Windows ISO Provisioning Tool v$currentVersion" -Level "Info"
        Write-CrateLog -Data "Modern CLI interface for ISO mounting, provisioning, and dismounting" -Level "Info"
        Write-CrateLog -Data "====================================================" -Level 'Info'
        Start-CrateOperation -Operation "Starting Crate initialization process..."
        #endregion

        #region Version Update Check (Priority 3)
        Write-CrateLog -Data "====================================================" -Level 'Info'
        Write-CrateLog -Data "    >>> STEP 2/8: VERSION UPDATE CHECK <<<" -Level 'Info'
        Write-CrateLog -Data "====================================================" -Level 'Info'

        # Check for module updates on PowerShell Gallery
        Write-CrateProgress -Message "Checking for module updates..."
        try {
            $galleryModule = Find-Module -Name 'Crate' -ErrorAction SilentlyContinue
            if ($galleryModule) {
                $latestVersion = $galleryModule.Version.ToString()
                $updateAvailable = [version]$latestVersion -gt [version]$currentVersion

                if ($updateAvailable) {
                    Write-CrateLog -Data "Update available: v$latestVersion (current: v$currentVersion)" -Level 'Warning'
                    Write-CrateLog -Data "Run 'Update-Module -Name Crate' to update" -Level 'Info'
                }
                else {
                    Write-CrateLog -Data "Module is up to date (v$currentVersion)" -Level 'Success'
                }
            }
            else {
                Write-CrateLog -Data "Could not check for updates (module not found on PowerShell Gallery)" -Level 'Warning'
            }
        }
        catch {
            Write-CrateLog -Data "Could not check for updates: $($_.Exception.Message)" -Level 'Warning'
        }
        #endregion
    }

    process {
        $Error.Clear()

        try {

            #region Administrative Privileges Validation (Priority 4)
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateLog -Data "    >>> STEP 3/8: ADMINISTRATIVE PRIVILEGES VALIDATION <<<" -Level 'Info'
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateProgress -Message "Validating administrative privileges..."
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $isAdmin) {
                throw "Crate requires administrative privileges. Please run as administrator."
            }
            Write-CrateLog -Data "Administrative privileges verified" -Level 'Success'
            #endregion

            #region System Environment Validation (Priority 5)
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateLog -Data "    >>> STEP 4/8: SYSTEM ENVIRONMENT VALIDATION <<<" -Level 'Info'
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateProgress -Message "Validating system environment..."

            # Check PowerShell version
            $psVersion = $PSVersionTable.PSVersion
            Write-CrateLog -Data "PowerShell version: $psVersion" -Level 'Info'

            # Check available disk space
            $systemDrive = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive }
            $freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
            Write-CrateLog -Data "Available disk space on $($env:SystemDrive): $freeSpaceGB GB" -Level 'Info'

            if ($freeSpaceGB -lt 10) {
                Write-CrateLog -Data "Warning: Low disk space ($freeSpaceGB GB). Recommended minimum: 10 GB" -Level 'Warning'
            }

            # Check DISM availability
            try {
                $dismPath = Get-Command 'dism.exe' -ErrorAction Stop
                Write-CrateLog -Data "DISM found at: $($dismPath.Source)" -Level 'Success'
            }
            catch {
                Write-CrateLog -Data "Warning: DISM not found in PATH" -Level 'Warning'
            }
            #endregion

            #region Workspace Structure Creation (Priority 6)
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateLog -Data "    >>> STEP 5/8: WORKSPACE STRUCTURE CREATION <<<" -Level 'Info'
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateProgress -Message "Creating workspace structure..."
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
                'Backup'
            )

            $createdFolders = 0
            $existingFolders = 0

            foreach ($folder in $workspaceStructure) {
                $fullPath = Join-Path $WorkspacePath $folder
                if (-not (Test-Path $fullPath)) {
                    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
                    Write-CrateLog -Data "Created workspace folder: $folder" -Level 'Info'
                    $createdFolders++
                }
                else {
                    $existingFolders++
                }
            }
            Write-CrateLog -Data "Workspace structure: $createdFolders new folders, $existingFolders existing" -Level 'Info'
            #endregion

            #region Configuration Management (Priority 7)
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateLog -Data "    >>> STEP 6/8: CONFIGURATION MANAGEMENT <<<" -Level 'Info'
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateProgress -Message "Initializing configuration..."
            $configPath = Join-Path $WorkspacePath 'Config\settings.json'

            if (-not (Test-Path $configPath) -or $Force) {
                $defaultConfig = @{
                    WorkspacePath   = $WorkspacePath
                    LogLevel        = 'Info'
                    MaxLogFiles     = 10
                    AutoCleanup     = $true
                    BackupEnabled   = $true
                    DefaultProfile  = 'Default'
                    CreatedDate     = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                    Version         = $currentVersion
                    LastUpdateCheck = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                } | ConvertTo-Json -Depth 3

                $defaultConfig | Out-File -FilePath $configPath -Encoding UTF8
                Write-CrateLog -Data "Created default configuration" -Level 'Info'
            }
            else {
                Write-CrateLog -Data "Configuration file already exists" -Level 'Info'
            }
            #endregion

            #region Global Variables and Final Setup (Priority 8)
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateLog -Data "    >>> STEP 7/8: GLOBAL VARIABLES & FINAL SETUP <<<" -Level 'Info'
            Write-CrateLog -Data "====================================================" -Level 'Info'
            Write-CrateProgress -Message "Finalizing environment setup..."

            # Set global variables
            $Script:CrateWorkspace = $WorkspacePath
            $Script:CrateInitialized = $true
            $Script:CrateVersion = $currentVersion

            Write-CrateLog -Data "Global variables configured" -Level 'Success'
            Write-CrateLog -Data "Workspace: $WorkspacePath" -Level 'Info'
            Write-CrateProgress -Message "Completing initialization..."
            Write-CrateLog -Data "====================================================" -Level 'Success'
            Write-CrateLog -Data "    >>> STEP 8/8: INITIALIZATION COMPLETED SUCCESSFULLY <<<" -Level 'Success'
            Write-CrateLog -Data "====================================================" -Level 'Success'
            #endregion

            Complete-CrateOperation -Operation "Crate Environment Initialization" -Success $true

            # Final success message
            Write-CrateLog -Data "Starting Crate interface..." -Level 'Success'
            for ($i = 5; $i -gt 0; $i--) {
                Write-Host "  $i seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }

            return $true
        }
        catch {
            Complete-CrateOperation -Operation "Crate Environment Initialization" -Success $false
            Write-CrateLog -Data "Initialization failed: $($_.Exception.Message)" -Level 'Error'
            return $false
        }
    }
}
