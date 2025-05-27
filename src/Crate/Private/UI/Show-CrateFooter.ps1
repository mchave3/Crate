<#
.SYNOPSIS
    Displays the Crate footer with credits and version information.

.DESCRIPTION
    Shows the footer section containing author credits and module version
    information at the bottom of the menu interface.

.EXAMPLE
    Show-CrateFooter
    Displays the footer with credits and version.

.NOTES
    Name:        Show-CrateFooter.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Show-CrateFooter {
    [CmdletBinding()]
    param()

    process {
        try {
            $version = Get-CrateVersion
            $creditColor  = "DarkGray"

            Write-Host ""
            Write-CenteredHost ("─" * 60) -ForegroundColor DarkGray
            Write-Host ""

            # Credits section - centered
            $creditLine1 = "📦 Created by Mickaël CHAVE | 🌟 Version $version"
            Write-CenteredHost $creditLine1 -ForegroundColor $creditColor

            $creditLine2 = "🔗 GitHub: https://github.com/mchave3/Crate"
            Write-CenteredHost $creditLine2 -ForegroundColor DarkCyan

            $creditLine3 = "📄 License: MIT License"
            Write-CenteredHost $creditLine3 -ForegroundColor DarkGray

            Write-Host ""
        }
        catch {
            Write-CenteredHost "📦 Crate | Version: Unknown | Created by Mickaël CHAVE" -ForegroundColor $creditColor
            Write-Host ""
        }
    }
}
