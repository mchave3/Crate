<#
.SYNOPSIS
    Displays a modern progress bar with detailed information.

.DESCRIPTION
    Creates visually appealing progress indicators for Crate operations with
    percentage completion, elapsed time, estimated time remaining, and current operation status.

.PARAMETER Activity
    The name of the activity being performed.

.PARAMETER Status
    Current status message.

.PARAMETER PercentComplete
    Percentage of completion (0-100).

.PARAMETER CurrentOperation
    Description of the current operation.

.PARAMETER SecondsRemaining
    Estimated seconds remaining.

.EXAMPLE
    Show-CrateProgress -Activity "Mounting ISO" -Status "Processing..." -PercentComplete 45 -CurrentOperation "Reading file system"

.NOTES
    Name:        Show-CrateProgress.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Show-CrateProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [Parameter()]
        [string]$Status = "Processing...",

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$PercentComplete = 0,

        [Parameter()]
        [string]$CurrentOperation,

        [Parameter()]
        [int]$SecondsRemaining = -1,

        [Parameter()]
        [int]$Id = 1
    )

    process {
        # Enhanced Write-Progress with modern styling
        $progressParams = @{
            Activity        = "🔄 $Activity"
            Status          = $Status
            PercentComplete = $PercentComplete
            Id              = $Id
        }

        if ($CurrentOperation) {
            $progressParams.CurrentOperation = $CurrentOperation
        }

        if ($SecondsRemaining -gt 0) {
            $progressParams.SecondsRemaining = $SecondsRemaining
        }

        Write-Progress @progressParams

        # Additional console output for enhanced feedback
        if ($PercentComplete -eq 0) {
            Write-Host "🔄 Starting: $Activity" -ForegroundColor Cyan
        }
        elseif ($PercentComplete -eq 100) {
            # Only show completion message if CrateLogger is not active to avoid duplication
            if (-not $Script:CrateLogger) {
                Write-Host "✅ Completed: $Activity" -ForegroundColor Green
            }
            Write-Progress -Activity $Activity -Completed -Id $Id
        }
    }
}
