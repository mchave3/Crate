<#
.SYNOPSIS
    This function logs messages with different severity levels.

.DESCRIPTION
    The `Write-CrateLog` function allows you to log messages with various severity levels such as Verbose, Debug, Info, Warning, Error, and Fatal.
    Each level corresponds to a different type of message, allowing for better categorization and handling of log output.

.NOTES
    Name:        Write-CrateLog.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Write-CrateLog -Data "This is an informational message." -Level "Info"
    Logs an informational message to the console.

.EXAMPLE
    Write-CrateLog -Data "This is a warning message." -Level "Warning"
    Logs a warning message to the console.

.EXAMPLE
    Write-CrateLog -Data "This is an error message." -Level "Error"
    Logs an error message to the console.
#>
function Write-CrateLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Data,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Verbose', 'Debug', 'Info', 'Warning', 'Error', 'Fatal')]
        [string]$Level = 'Info'
    )

    process {<#
.SYNOPSIS
    Enhanced logging function for Crate with file output and modern formatting.

.DESCRIPTION
    The Write-CrateLog function provides comprehensive logging capabilities with:
    - Console output with colors and modern formatting
    - File-based logging with rotation
    - Different severity levels
    - Caller function detection
    - Timestamp formatting

.PARAMETER Data
    The message to log.

.PARAMETER Level
    The severity level of the message.

.EXAMPLE
    Write-CrateLog -Data "Starting ISO mount process" -Level "Info"

.EXAMPLE
    Write-CrateLog -Data "Failed to mount ISO" -Level "Error"

.NOTES
    Name:        Write-CrateLog.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
    Logs are saved to workspace\Logs directory with rotation.
#>
function Write-CrateLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Data,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Verbose', 'Debug', 'Info', 'Warning', 'Error', 'Fatal', 'Success')]
        [string]$Level = 'Info'
    )

    process {
        # Get the calling function name from the call stack
        $CallerName = if ((Get-PSCallStack).Count -gt 1) {
            $FunctionName = (Get-PSCallStack)[1].FunctionName
            # Remove the <Process> part if it exists
            if ($FunctionName -match '^(.+)<.+>$') {
                $matches[1]
            }
            else {
                $FunctionName
            }
        }
        else {
            $MyInvocation.MyCommand.Name
        }

        # Prepare log message
        $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        $LogMessage = "[$Timestamp] [$Level] [$CallerName] $Data"

        # Console output with modern formatting
        $emoji = switch ($Level) {
            'Verbose' { '🔍' }
            'Debug'   { '🐛' }
            'Info'    { 'ℹ️' }
            'Warning' { '⚠️' }
            'Error'   { '❌' }
            'Fatal'   { '💥' }
            'Success' { '✅' }
        }

        $color = switch ($Level) {
            'Verbose' { 'DarkGray' }
            'Debug'   { 'Cyan' }
            'Info'    { 'White' }
            'Warning' { 'Yellow' }
            'Error'   { 'Red' }
            'Fatal'   { 'Magenta' }
            'Success' { 'Green' }
        }

        # Console output
        switch ($Level) {
            'Verbose' {
                if ($VerbosePreference -ne 'SilentlyContinue') {
                    Write-Host "$emoji $Data" -ForegroundColor $color
                }
            }
            'Debug'   {
                if ($DebugPreference -ne 'SilentlyContinue') {
                    Write-Host "$emoji $Data" -ForegroundColor $color
                }
            }
            default {
                Write-Host "$emoji $Data" -ForegroundColor $color
            }
        }

        # File logging (if workspace is initialized)
        if ($global:CrateWorkspace) {
            try {
                $logDir = Join-Path $global:CrateWorkspace 'Logs'
                if (-not (Test-Path $logDir)) {
                    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
                }

                $logFile = Join-Path $logDir "Crate_$(Get-Date -Format 'yyyyMMdd').log"
                $LogMessage | Out-File -FilePath $logFile -Append -Encoding UTF8

                # Log rotation - keep only last 10 files
                $logFiles = Get-ChildItem -Path $logDir -Filter "Crate_*.log" | Sort-Object CreationTime -Descending
                if ($logFiles.Count -gt 10) {
                    $logFiles | Select-Object -Skip 10 | Remove-Item -Force
                }
            }
            catch {
                # Fail silently for file logging issues
            }
        }
    }
}
    }
}
