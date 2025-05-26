<#
.SYNOPSIS
    Modern logging system for Crate with advanced features and UI compatibility.

.DESCRIPTION
    Advanced logging system that provides:
    - Class-based architecture for better performance
    - Silent mode for UI compatibility
    - Automatic log rotation
    - In-memory buffer for recent logs
    - Structured operation tracking
    - Modern console output with emojis

.NOTES
    Name:        Write-CrateLog.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

    This file contains the CrateLogger class and all logging functions.
#>

#region CrateLogger Class
class CrateLogger {
    [string]$LogPath
    [string]$Level
    [bool]$SilentMode
    [System.Collections.Queue]$Buffer

    CrateLogger([string]$logPath) {
        $this.LogPath = $logPath
        $this.Level = "INFO"
        $this.SilentMode = $false
        $this.Buffer = [System.Collections.Queue]::new()
        $this.InitializeLog()
    }

    [void]InitializeLog() {
        $logDir = Split-Path $this.LogPath -Parent
        if (!(Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        # Log rotation if file exceeds 10MB
        if ((Test-Path $this.LogPath) -and (Get-Item $this.LogPath).Length -gt 10MB) {
            $this.RotateLog()
        }
    }

    [void]RotateLog() {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $rotatedPath = $this.LogPath -replace "\.log$", "_$timestamp.log"
        Move-Item -Path $this.LogPath -Destination $rotatedPath -Force

        # Keep only the last 10 log files
        $logDir = Split-Path $this.LogPath -Parent
        $logFiles = Get-ChildItem -Path $logDir -Filter "Crate_*.log" | Sort-Object CreationTime -Descending
        if ($logFiles.Count -gt 10) {
            $logFiles | Select-Object -Skip 10 | Remove-Item -Force
        }
    }

    [void]Write([string]$message, [string]$level = "INFO", [bool]$forceDisplay = $false) {
        $caller = $this.GetCallerName()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $logEntry = "[$timestamp] [$level] [$caller] $message"        # File writing (always)
        try {
            Add-Content -Path $this.LogPath -Value $logEntry -Encoding UTF8
        }
        catch {
            # Fail silently for file logging issues - no action needed
            Write-Debug "Failed to write to log file: $($_.Exception.Message)"
        }

        # Conditional display
        if (!$this.SilentMode -or $forceDisplay -or $level -in @("ERROR", "WARNING", "FATAL")) {
            $this.WriteToConsole($message, $level)
        }

        # Buffer for UI
        $this.Buffer.Enqueue(@{
                Timestamp = Get-Date
                Level     = $level
                Message   = $message
                Caller    = $caller
            })

        # Keep only the last 100
        while ($this.Buffer.Count -gt 100) {
            $this.Buffer.Dequeue() | Out-Null
        }
    }

    [string]GetCallerName() {
        $callStack = Get-PSCallStack
        if ($callStack.Count -gt 3) {
            $functionName = $callStack[3].FunctionName
            # Remove the <Process> part if it exists
            if ($functionName -match '^(.+)<.+>$') {
                return $matches[1]
            }
            else {
                return $functionName
            }
        }
        else {
            return "Unknown"
        }
    }

    [void]WriteToConsole([string]$message, [string]$level) {
        $emoji = switch ($level) {
            "ERROR" { "❌" }
            "WARNING" { "⚠️" }
            "SUCCESS" { "✅" }
            "DEBUG" { "🐛" }
            "VERBOSE" { "🔍" }
            "FATAL" { "💥" }
            default { "ℹ️" }
        }

        $color = switch ($level) {
            "ERROR" { "Red" }
            "WARNING" { "Yellow" }
            "SUCCESS" { "Green" }
            "DEBUG" { "Cyan" }
            "VERBOSE" { "DarkGray" }
            "FATAL" { "Magenta" }
            default { "White" }
        }

        Write-Host "$emoji $message" -ForegroundColor $color
    }

    [void]StartOperation([string]$operation) {
        $this.Write("🚀 Starting: $operation", "INFO")
    }    [void]EndOperation([string]$operation, [bool]$success = $true) {
        $emoji = if ($success) { "✅" } else { "❌" }
        $levelValue = if ($success) { "SUCCESS" } else { "ERROR" }
        $this.Write("$emoji Completed: $operation", $levelValue)
    }

    [void]Progress([string]$message) {
        $this.Write("⏳ $message", "INFO")
    }

    [void]SetSilentMode([bool]$silent) {
        $this.SilentMode = $silent
    }

    [array]GetRecentLogs([int]$count = 20) {
        return $this.Buffer.ToArray() | Select-Object -Last $count
    }
}
#endregion

#region Public Functions

# Main logging function - backward compatible
function Write-CrateLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("Message")]
        [string]$Data,

        [Parameter()]
        [ValidateSet("Verbose", "Debug", "Info", "Warning", "Error", "Fatal", "Success")]
        [string]$Level = "Info",

        [Parameter()]
        [switch]$Force
    )

    process {
        # Normalize level to uppercase for internal consistency
        $normalizedLevel = $Level.ToUpper()

        # Initialize logger if not exists
        if (!$Script:CrateLogger) {
            $logPath = if ($Script:CrateWorkspace) {
                Join-Path $Script:CrateWorkspace "Logs\Crate_$(Get-Date -Format 'yyyyMMdd').log"
            }
            else {
                "$env:TEMP\Crate_$(Get-Date -Format 'yyyyMMdd').log"
            }
            $Script:CrateLogger = [CrateLogger]::new($logPath)
        }

        $Script:CrateLogger.Write($Data, $normalizedLevel, $Force.IsPresent)
    }
}

# Operation tracking functions
function Start-CrateOperation {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Operation
    )

    if ($PSCmdlet.ShouldProcess($Operation, "Start operation")) {
        if ($Script:CrateLogger) {
            $Script:CrateLogger.StartOperation($Operation)
        }
        else {
            Write-CrateLog -Data "Starting: $Operation" -Level "Info"
        }
    }
}

function Complete-CrateOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Operation,

        [Parameter()]
        [bool]$Success = $true
    )

    if ($Script:CrateLogger) {
        $Script:CrateLogger.EndOperation($Operation, $Success)
    }
    else {
        $level = if ($Success) { "Success" } else { "Error" }
        $emoji = if ($Success) { "✅" } else { "❌" }
        Write-CrateLog -Data "$emoji Completed: $Operation" -Level $level
    }
}

function Write-CrateProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Script:CrateLogger) {
        $Script:CrateLogger.Progress($Message)
    }
    else {
        Write-CrateLog -Data "⏳ $Message" -Level "Info"
    }
}

function Set-CrateLogSilent {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Silent
    )

    if ($PSCmdlet.ShouldProcess("Logger", "Set silent mode to $Silent")) {
        if ($Script:CrateLogger) {
            $Script:CrateLogger.SetSilentMode($Silent)
        }
    }
}

function Get-CrateRecentLog {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Count = 20
    )

    if ($Script:CrateLogger) {
        return $Script:CrateLogger.GetRecentLogs($Count)
    }
    else {
        return @()
    }
}

function Reset-CrateLogger {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess("Logger", "Reset Crate logger")) {
        $Script:CrateLogger = $null
    }
}

#endregion
