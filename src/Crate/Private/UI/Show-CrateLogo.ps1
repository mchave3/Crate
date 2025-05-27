<#
.SYNOPSIS
    Displays the Crate logo and module name in ASCII art.

.DESCRIPTION
    Shows the Crate logo in ASCII art format along with the module name
    for branding and visual identity in the terminal interface.

.EXAMPLE
    Show-CrateLogo
    Displays the Crate logo and module name.

.NOTES
    Name:        Show-CrateLogo.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
#>
function Show-CrateLogo {
    [CmdletBinding()]
    param()

    process {
        $nameColor = "White"

        Write-Host ""
        Write-Host "        ███████╗██████╗  █████╗ ████████╗███████╗" -ForegroundColor $nameColor
        Write-Host "        ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝" -ForegroundColor $nameColor
        Write-Host "        ██║     ██████╔╝███████║   ██║   █████╗  " -ForegroundColor $nameColor
        Write-Host "        ██║     ██╔══██╗██╔══██║   ██║   ██╔══╝  " -ForegroundColor $nameColor
        Write-Host "        ╚██████╗██║  ██║██║  ██║   ██║   ███████╗" -ForegroundColor $nameColor
        Write-Host "         ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝" -ForegroundColor $nameColor
        Write-Host ""
        Write-Host "              Windows ISO Provisioning Tool" -ForegroundColor DarkGray
        Write-Host ""
    }
}
