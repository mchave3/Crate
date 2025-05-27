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

    # Write a log entry to file, console, and buffer with UI-only support
    [void]Write([string]$message, [string]$level = "INFO", [bool]$forceDisplay = $false, [bool]$noFileLog = $false) {
        $caller = $this.GetCallerName()

        # Create unified format for both file and console
        $formattedEntry = $this.FormatLogEntry("", $level, $caller, $message)

        # Write to log file unless it's a UI-only message
        if (!$noFileLog) {
            try {
                Add-Content -Path $this.LogPath -Value $formattedEntry -Encoding UTF8
            }
            catch {
                # Fail silently for file logging issues to avoid breaking the application
                Write-Debug "Failed to write to log file: $($_.Exception.Message)"
            }
        }

        # Display to console based on silent mode and level
        # UI levels (PROMPT, HEADER, SEPARATOR) are always displayed unless in silent mode
        $isUILevel = $level -in @("PROMPT", "HEADER", "SEPARATOR")
        if (!$this.SilentMode -or $forceDisplay -or $level -in @("ERROR", "WARNING", "FATAL") -or $isUILevel) {
            $this.WriteToConsole("", $level, $caller, $message)
        }

        # Add to in-memory buffer for UI access (skip UI-only messages from buffer)
        if (!$noFileLog) {
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

    # Write a formatted message to the console with structured 4-column layout
    [void]WriteToConsole([string]$timestamp, [string]$level, [string]$caller, [string]$message) {
        # Define color for each log level
        $color = switch ($level) {
            "ERROR" { "Red" }
            "WARNING" { "Yellow" }
            "SUCCESS" { "Green" }
            "DEBUG" { "Cyan" }
            "VERBOSE" { "DarkGray" }
            "FATAL" { "Magenta" }
            "PROMPT" { "Magenta" }
            "HEADER" { "White" }
            "SEPARATOR" { "DarkGray" }
            default { "White" }
        }

        # Special handling for UI-specific levels (keep emojis for menus/UI)
        if ($level -eq "HEADER") {
            Write-Host ""
            Write-Host "🚀 $message" -ForegroundColor $color -BackgroundColor DarkBlue
            Write-Host ""
        }
        elseif ($level -eq "SEPARATOR") {
            # For separator, ignore the message and always show a line
            Write-Host ("─" * 80) -ForegroundColor $color
        }
        elseif ($level -eq "PROMPT") {
            # For prompts, use emoji but also show in structured format
            Write-Host "❓ $message" -ForegroundColor $color
        }
        else {
            # Use unified format for console output (ignore passed timestamp, generate new one)
            $formattedEntry = $this.FormatLogEntry("", $level, $caller, $message)
            Write-Host $formattedEntry -ForegroundColor $color
        }
    }

    # Format log entry with unified professional structure (Format 3: Brackets)
    [string]FormatLogEntry([string]$ignored, [string]$level, [string]$caller, [string]$message) {
        # Generate timestamp in correct format
        $timestamp = Get-Date -Format G

        # Clean up caller name for better readability
        $cleanCaller = if ($caller -eq "Unknown" -or $caller -eq "<ScriptBlock>") {
            "System"
        }
        else {
            $caller -replace "^(.*)<.*>$", '$1'  # Remove <Process> part if exists
        }

        # Format: [timestamp] [level] [caller] message with aligned level
        $alignedLevel = $level.PadRight(7)  # Align to longest level "WARNING" (7 chars)
        return "[$timestamp] [$alignedLevel] [$cleanCaller] $message"
    }    # Log the start of an operation
    [void]StartOperation([string]$operation) {
        $this.Write("Starting: $operation", "INFO", $false, $false)
    }

    # Log the completion of an operation with success status
    [void]EndOperation([string]$operation, [bool]$success = $true) {
        $levelValue = if ($success) { "SUCCESS" } else { "ERROR" }
        $statusText = if ($success) { "Completed" } else { "Failed" }
        $this.Write("${statusText}: $operation", $levelValue, $false, $false)
    }

    # Log a progress message for ongoing operations
    [void]Progress([string]$message) {
        $this.Write("$message", "INFO", $false, $false)
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