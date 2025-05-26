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
    Name:        CrateLogger.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate
#>

class CrateLogger {
    # Path to the log file
    [string]$LogPath

    # Current logging level
    [string]$Level

    # Silent mode flag for UI compatibility
    [bool]$SilentMode

    # In-memory buffer for recent log entries
    [System.Collections.Queue]$Buffer

    # Constructor: Initialize the logger with specified log path
    CrateLogger([string]$logPath) {
        $this.LogPath = $logPath
        $this.Level = "INFO"
        $this.SilentMode = $false
        $this.Buffer = [System.Collections.Queue]::new()
        $this.InitializeLog()
    }

    # Initialize the log file and directory, handle rotation if needed
    [void]InitializeLog() {
        # Create log directory if it doesn't exist
        $logDir = Split-Path $this.LogPath -Parent
        if (!(Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        # Rotate log file if it exceeds 10MB
        if ((Test-Path $this.LogPath) -and (Get-Item $this.LogPath).Length -gt 10MB) {
            $this.RotateLog()
        }
    }

    # Rotate the current log file and clean up old log files
    [void]RotateLog() {
        # Create rotated log file with timestamp
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $rotatedPath = $this.LogPath -replace "\.log$", "_$timestamp.log"
        Move-Item -Path $this.LogPath -Destination $rotatedPath -Force

        # Keep only the last 10 log files to prevent disk space issues
        $logDir = Split-Path $this.LogPath -Parent
        $logFiles = Get-ChildItem -Path $logDir -Filter "Crate_*.log" | Sort-Object CreationTime -Descending
        if ($logFiles.Count -gt 10) {
            $logFiles | Select-Object -Skip 10 | Remove-Item -Force
        }
    }

    # Write a log entry to file, console, and buffer
    [void]Write([string]$message, [string]$level = "INFO", [bool]$forceDisplay = $false) {
        $caller = $this.GetCallerName()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $logEntry = "[$timestamp] [$level] [$caller] $message"

        # Always write to log file
        try {
            Add-Content -Path $this.LogPath -Value $logEntry -Encoding UTF8
        }
        catch {
            # Fail silently for file logging issues to avoid breaking the application
            Write-Debug "Failed to write to log file: $($_.Exception.Message)"
        }

        # Display to console based on silent mode and level
        if (!$this.SilentMode -or $forceDisplay -or $level -in @("ERROR", "WARNING", "FATAL")) {
            $this.WriteToConsole($message, $level)
        }

        # Add to in-memory buffer for UI access
        $this.Buffer.Enqueue(@{
                Timestamp = Get-Date
                Level     = $level
                Message   = $message
                Caller    = $caller
            })

        # Maintain buffer size limit
        while ($this.Buffer.Count -gt 100) {
            $this.Buffer.Dequeue() | Out-Null
        }
    }

    # Get the name of the calling function for better log traceability
    [string]GetCallerName() {
        $callStack = Get-PSCallStack
        if ($callStack.Count -gt 3) {
            $functionName = $callStack[3].FunctionName
            # Remove the <Process> part if it exists in the function name
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

    # Write a formatted message to the console with emojis and colors
    [void]WriteToConsole([string]$message, [string]$level) {
        # Define emoji for each log level
        $emoji = switch ($level) {
            "ERROR" { "❌" }
            "WARNING" { "⚠️" }
            "SUCCESS" { "✅" }
            "DEBUG" { "🐛" }
            "VERBOSE" { "🔍" }
            "FATAL" { "💥" }
            default { "ℹ️" }
        }

        # Define color for each log level
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

    # Log the start of an operation
    [void]StartOperation([string]$operation) {
        $this.Write("🚀 Starting: $operation", "INFO")
    }

    # Log the completion of an operation with success status
    [void]EndOperation([string]$operation, [bool]$success = $true) {
        $emoji = if ($success) { "✅" } else { "❌" }
        $levelValue = if ($success) { "SUCCESS" } else { "ERROR" }
        $this.Write("$emoji Completed: $operation", $levelValue)
    }

    # Log a progress message for ongoing operations
    [void]Progress([string]$message) {
        $this.Write("⏳ $message", "INFO")
    }

    # Enable or disable silent mode for UI compatibility
    [void]SetSilentMode([bool]$silent) {
        $this.SilentMode = $silent
    }

    # Retrieve recent log entries from the in-memory buffer
    [array]GetRecentLogs([int]$count = 20) {
        return $this.Buffer.ToArray() | Select-Object -Last $count
    }
}