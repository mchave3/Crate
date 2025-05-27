<#
.SYNOPSIS
    Displays an interactive menu for Crate operations.

.DESCRIPTION
    Creates a modern, interactive command-line menu for navigating Crate's
    Windows ISO provisioning features with keyboard navigation and visual feedback.

.PARAMETER Title
    The title to display at the top of the menu.

.PARAMETER Options
    Array of menu options to display.

.PARAMETER AllowMultipleSelection
    Allow selection of multiple options.

.EXAMPLE
    $options = @('Mount ISO', 'Provision Updates', 'Add Language Pack', 'Dismount & Create ISO', 'Exit')
    $selection = Show-CrateMenu -Title "Crate Main Menu" -Options $options

.NOTES
    Name:        Show-CrateMenu.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
    Requires PowerShell 7.4+ for modern console features.
#>
function Show-CrateMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string[]]$Options,

        [Parameter()]
        [switch]$AllowMultipleSelection
    )

    process {
        $selectedIndex = 0
        $selectedItems = @()

        do {
            Clear-Host

            # ===== PARTIE 1: LOGO + NOM DU MODULE EN ASCII ART =====
            Show-CrateLogo

            # ===== PARTIE 2: MENU =====
            Write-Host ""
            Write-Host "🚀 $Title" -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host ("─" * ($Title.Length + 4)) -ForegroundColor DarkGray
            Write-Host ""

            # Display options
            for ($i = 0; $i -lt $Options.Length; $i++) {
                $prefix = "  "
                $color = "White"

                if ($i -eq $selectedIndex) {
                    $prefix = "▶ "
                    $color = "Yellow"
                }

                if ($AllowMultipleSelection -and $selectedItems -contains $i) {
                    $prefix += "☑ "
                }
                elseif ($AllowMultipleSelection) {
                    $prefix += "☐ "
                }

                Write-Host "$prefix$($Options[$i])" -ForegroundColor $color
            }            Write-Host ""
            if ($AllowMultipleSelection) {
                Write-Host "Navigation: ↑/↓ arrows, Space to select/deselect, Enter to confirm, Q to quit" -ForegroundColor DarkGray
            }
            else {
                Write-Host "Navigation: ↑/↓ arrows, Enter to select, Q to quit" -ForegroundColor DarkGray
            }

            # ===== PARTIE 3: CREDIT + VERSION DU MODULE =====
            Show-CrateFooter

            # Get user input
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            switch ($key.VirtualKeyCode) {
                38 {
                    # Up arrow
                    $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $Options.Length - 1 }
                }
                40 {
                    # Down arrow
                    $selectedIndex = if ($selectedIndex -lt ($Options.Length - 1)) { $selectedIndex + 1 } else { 0 }
                }
                32 {
                    # Space (for multiple selection)
                    if ($AllowMultipleSelection) {
                        if ($selectedItems -contains $selectedIndex) {
                            $selectedItems = $selectedItems | Where-Object { $_ -ne $selectedIndex }
                        }
                        else {
                            $selectedItems += $selectedIndex
                        }
                    }
                }
                13 {
                    # Enter
                    if ($AllowMultipleSelection) {
                        return $selectedItems | ForEach-Object { $Options[$_] }
                    }
                    else {
                        return $Options[$selectedIndex]
                    }
                }
                81 {
                    # Q
                    return $null
                }
            }
        } while ($true)
    }
}
