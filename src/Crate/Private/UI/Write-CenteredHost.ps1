<#
.SYNOPSIS
    Writes text centered horizontally in the console window.

.DESCRIPTION
    Centers text output in the PowerShell console by calculating the console width
    and adding appropriate left padding. Supports colored text output.

.PARAMETER Text
    The text to display centered.

.PARAMETER ForegroundColor
    The foreground color for the text. Default is White.

.PARAMETER BackgroundColor
    The background color for the text. Optional.

.EXAMPLE
    Write-CenteredHost "Hello World" -ForegroundColor Green
    Displays "Hello World" centered in green text.

.EXAMPLE
    Write-CenteredHost "Title" -ForegroundColor White -BackgroundColor DarkBlue
    Displays "Title" centered with white text on dark blue background.

.NOTES
    Name:        Write-CenteredHost.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Write-CenteredHost {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter()]
        [string]$ForegroundColor = "White",

        [Parameter()]
        [string]$BackgroundColor = $null
    )

    process {
        try {
            $consoleWidth = $Host.UI.RawUI.WindowSize.Width
            $textLength = $Text.Length
            $leftPadding = [Math]::Max(0, [Math]::Floor(($consoleWidth - $textLength) / 2))

            if ($BackgroundColor) {
                # If BackgroundColor is specified, display spaces without background color first
                # then display text with the specified background color
                Write-Host (" " * $leftPadding) -NoNewline
                Write-Host $Text -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
            }
            else {
                # Normal behavior without background color
                Write-Host (" " * $leftPadding + $Text) -ForegroundColor $ForegroundColor
            }
        }
        catch {
            # Fallback if console width can't be determined
            $params = @{
                Object          = $Text
                ForegroundColor = $ForegroundColor
            }
            if ($BackgroundColor) {
                $params.BackgroundColor = $BackgroundColor
            }
            Write-Host @params
        }
    }
}
