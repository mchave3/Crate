<#
.SYNOPSIS
    Main logging function for the Crate system

.DESCRIPTION
    Provides the primary logging functionality for the Crate system with
    advanced features including level-based logging, automatic log file
    management, and integration with the CrateLogger class.

.NOTES
    Name:        Write-CrateLog.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.PARAMETER Data
    The message or data to log

.PARAMETER Level
    The logging level: Verbose, Debug, Info, Warning, Error, Fatal, Success

.PARAMETER Force
    Forces the log entry to be written even if normally filtered

.PARAMETER NoFileLog
    Prevents writing to the log file (UI-only output)

.EXAMPLE
    Write-CrateLog -Data "Operation completed successfully" -Level "Success"
    Logs a success message

.EXAMPLE
    Write-CrateLog -Data "Select an option:" -Level "Prompt" -NoFileLog
    Displays a UI prompt without logging to file
#>

function Write-CrateLog {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("Message")]
        [string]$Data,

        [Parameter()]
        [ValidateSet("Verbose", "Debug", "Info", "Warning", "Error", "Fatal", "Success", "Prompt", "Header", "Separator")]
        [string]$Level = "Info",

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$NoFileLog
    )    process {
        # Normalize level to uppercase for internal consistency
        $normalizedLevel = $Level.ToUpper()

        # Initialize logger if not exists
        if (!$Script:CrateLogger) {
            try {
                Write-Debug "CrateWorkspace value: '$Script:CrateWorkspace'"
                $logPath = if ($Script:CrateWorkspace) {
                    Join-Path $Script:CrateWorkspace "Logs\Crate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                }
                else {
                    "$env:TEMP\Crate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                }

                Write-Debug "Creating CrateLogger with path: $logPath"
                $Script:CrateLogger = [CrateLogger]::new($logPath)
                Write-Debug "CrateLogger created successfully"
            }
            catch {
                Write-Error "Failed to create CrateLogger: $($_.Exception.Message)"
                # Fallback to simple console output
                Write-Host "[$normalizedLevel] $Data" -ForegroundColor Yellow
                return
            }
        }

        try {
            $Script:CrateLogger.Write($Data, $normalizedLevel, $Force.IsPresent, $NoFileLog.IsPresent)
        }
        catch {
            Write-Error "Failed to write to CrateLogger: $($_.Exception.Message)"
            # Fallback to simple console output
            Write-Host "[$normalizedLevel] $Data" -ForegroundColor Yellow
        }
    }
}
