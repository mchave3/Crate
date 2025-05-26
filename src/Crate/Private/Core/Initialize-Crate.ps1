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
        # Initialize logger early to capture all initialization logs
        Write-Host "Current logger: $Script:CrateLogger" -ForegroundColor Cyan

        # Always reinitialize logger to ensure it uses the correct workspace path
        # Ensure logs directory exists
        $logsPath = Join-Path $WorkspacePath 'Logs'
        Write-Host "Checking logs path: $logsPath" -ForegroundColor Yellow

        if (-not (Test-Path $logsPath)) {
            try {
                New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
                Write-Host "Created logs directory: $logsPath" -ForegroundColor Green
            }
            catch {
                Write-Host "Error creating logs directory: $($_.Exception.Message)" -ForegroundColor Red
                throw
            }
        }
        else {
            Write-Host "Logs directory already exists: $logsPath" -ForegroundColor Green
        }

        # Initialize the logger
        $logFile = Join-Path $logsPath "Crate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        Write-Host "Creating logger with file: $logFile" -ForegroundColor Yellow

        try {
            $Script:CrateLogger = [CrateLogger]::new($logFile)
            Write-Host "Logger created successfully" -ForegroundColor Green

            # Test if we can write to the log file
            "Test log entry - $(Get-Date)" | Out-File -FilePath $logFile -Append -Encoding UTF8
            Write-Host "Test write to log file successful" -ForegroundColor Green
        }
        catch {
            Write-Host "Error creating logger: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }

        # Log the start of initialization
        Write-CrateLog -Data "Starting Crate initialization process" -Level 'Info'
        Start-CrateOperation -Operation "Crate Environment Initialization"
    }

    process {
        $Error.Clear()

        try {
            # Check if running as administrator
            Write-CrateProgress -Message "Checking administrative privileges"
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $isAdmin) {
                throw "Crate requires administrative privileges. Please run as administrator."
            }
            Write-CrateLog -Data "Administrative privileges verified" -Level 'Success'

            # Create workspace structure
            Write-CrateProgress -Message "Creating workspace structure"
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

            foreach ($folder in $workspaceStructure) {
                $fullPath = Join-Path $WorkspacePath $folder
                if (-not (Test-Path $fullPath)) {
                    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
                    Write-CrateLog -Data "Created workspace folder: $fullPath" -Level 'Info'
                }
                else {
                    Write-CrateLog -Data "Workspace folder already exists: $fullPath" -Level 'Info'
                }
            }

            # Initialize configuration
            Write-CrateProgress -Message "Initializing configuration"
            $configPath = Join-Path $WorkspacePath 'Config\settings.json'
            if (-not (Test-Path $configPath) -or $Force) {
                $defaultConfig = @{
                    WorkspacePath  = $WorkspacePath
                    LogLevel       = 'Info'
                    MaxLogFiles    = 10
                    AutoCleanup    = $true
                    BackupEnabled  = $true
                    DefaultProfile = 'Default'
                    CreatedDate    = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                    Version        = '25.5.26.1'
                } | ConvertTo-Json -Depth 3

                $defaultConfig | Out-File -FilePath $configPath -Encoding UTF8
                Write-CrateLog -Data "Created default configuration: $configPath" -Level 'Info'
            }            # Set global variables
            Write-CrateProgress -Message "Setting global variables"
            $Script:CrateWorkspace = $WorkspacePath
            $Script:CrateInitialized = $true

            Complete-CrateOperation -Operation "Crate Environment Initialization" -Success $true

            Write-CrateLog -Data "Workspace: $WorkspacePath" -Level 'Info'

            # Countdown before showing menu
            Write-CrateLog -Data "Initialization completed successfully - Starting in:" -Level 'Success'
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
