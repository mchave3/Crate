<#
.SYNOPSIS
    Displays formatted output with modern styling for Crate.

.DESCRIPTION
    Provides consistent, modern terminal output with colors, emojis, and formatting
    for the Crate Windows ISO provisioning tool.

.PARAMETER Message
    The message to display.

.PARAMETER ForegroundColor
    The color to use for the text.

.PARAMETER Type
    The type of message for automatic styling.

.EXAMPLE
    Write-CrateOutput -Message "Process completed successfully" -Type Success

.EXAMPLE
    Write-CrateOutput -Message "Select an option:" -Type Prompt

.NOTES
    Name:        Write-CrateOutput.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Write-CrateOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [System.ConsoleColor]$ForegroundColor,

        [Parameter()]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Prompt', 'Header', 'Separator')]
        [string]$Type
    )

    process {
        if ($Type) {
            switch ($Type) {
                'Info' {
                    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
                }
                'Success' {
                    Write-Host "✅ $Message" -ForegroundColor Green
                }
                'Warning' {
                    Write-Host "⚠️  $Message" -ForegroundColor Yellow
                }
                'Error' {
                    Write-Host "❌ $Message" -ForegroundColor Red
                }
                'Prompt' {
                    Write-Host "❓ $Message" -ForegroundColor Magenta
                }
                'Header' {
                    Write-Host ""
                    Write-Host "🚀 $Message" -ForegroundColor White -BackgroundColor DarkBlue
                    Write-Host ""
                }
                'Separator' {
                    Write-Host "─" * 60 -ForegroundColor DarkGray
                }
            }
        }
        elseif ($ForegroundColor) {
            Write-Host $Message -ForegroundColor $ForegroundColor
        }
        else {
            Write-Host $Message
        }
    }
}
