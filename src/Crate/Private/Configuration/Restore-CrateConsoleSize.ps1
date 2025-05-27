<#
.SYNOPSIS
    Restores the original console size if it was saved.

.DESCRIPTION
    Restores the PowerShell console to its original size that was saved
    when Set-CrateConsoleSize was called with -SaveOriginal.

.EXAMPLE
    Restore-CrateConsoleSize
    Restores the console to its original size.

.NOTES
    Name:        Restore-CrateConsoleSize.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

    This function requires that Set-CrateConsoleSize was previously called with -SaveOriginal.
#>
function Restore-CrateConsoleSize {
    [CmdletBinding()]
    param()

    process {
        try {
            if ($script:OriginalConsoleSize) {
                $Host.UI.RawUI.BufferSize = $script:OriginalConsoleSize.BufferSize
                $Host.UI.RawUI.WindowSize = $script:OriginalConsoleSize.WindowSize

                Write-Host "Console size restored to original dimensions" -ForegroundColor Green
                Write-Verbose "Restored size: $($script:OriginalConsoleSize.WindowSize.Width)x$($script:OriginalConsoleSize.WindowSize.Height)"

                # Clear the saved size
                $script:OriginalConsoleSize = $null
            }
            else {
                Write-Warning "No original console size was saved. Use Set-CrateConsoleSize -SaveOriginal first."
            }
        }
        catch {
            Write-Warning "Failed to restore console size: $($_.Exception.Message)"
        }
    }
}
