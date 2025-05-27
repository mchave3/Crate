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
            $creditColor = "DarkGray"
            $versionColor = "Green"
            $authorColor = "DarkCyan"

            Write-Host ""
            Write-Host ("─" * 80) -ForegroundColor DarkGray
            Write-Host ""

            # Credits section
            Write-Host "  📦 Created by " -ForegroundColor $creditColor -NoNewline
            Write-Host "Mickaël CHAVE" -ForegroundColor $authorColor -NoNewline
            Write-Host " | 🌟 Version " -ForegroundColor $creditColor -NoNewline
            Write-Host $version -ForegroundColor $versionColor

            Write-Host "  🔗 GitHub: " -ForegroundColor $creditColor -NoNewline
            Write-Host "https://github.com/mchave3/Crate" -ForegroundColor DarkCyan

            Write-Host "  📄 License: " -ForegroundColor $creditColor -NoNewline
            Write-Host "MIT License" -ForegroundColor DarkGray

            Write-Host ""
        }
        catch {
            Write-Host "  📦 Crate | Version: Unknown | Created by Mickaël CHAVE" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
