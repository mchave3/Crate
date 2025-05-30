<#
.SYNOPSIS
    Displays an interactive menu for Crate operations.

.DESCRIPTION
    Creates a modern, interactive command-line menu for navigating Crate's
    Windows ISO provisioning features with keyboard navigation and visual feedback.

.NOTES
    Name:        Show-CrateMenu.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.30.3
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.PARAMETER Title
    The title to display at the top of the menu.

.PARAMETER Options
    Array of menu options to display.

.PARAMETER AllowMultipleSelection
    Allow selection of multiple options.

.EXAMPLE
    $options = @('Mount ISO', 'Provision Updates', 'Add Language Pack', 'Dismount & Create ISO', 'Exit')
    $selection = Show-CrateMenu -Title "Crate Main Menu" -Options $options
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

            # Display the Crate logo and module branding
            Show-CrateLogo

            # Display the main menu title with visual separators
            Write-Host ""
            Write-CenteredHost "🚀 $Title" -ForegroundColor White -BackgroundColor DarkBlue
            Write-CenteredHost ("─" * ($Title.Length + 4)) -ForegroundColor DarkGray
            Write-Host ""

            # Calculate centering for menu items based on console width
            try {
                $consoleWidth = $Host.UI.RawUI.WindowSize.Width
                $maxOptionLength = ($Options | Measure-Object -Property Length -Maximum).Maximum + 4 # +4 for prefix
                $menuLeftPadding = [Math]::Max(0, [Math]::Floor(($consoleWidth - $maxOptionLength) / 2))
            }
            catch {
                $menuLeftPadding = 0
            }

            # Render each menu option with appropriate styling and selection state
            for ($i = 0; $i -lt $Options.Length; $i++) {
                $prefix = "  "
                $color = "White"

                # Highlight the currently selected option
                if ($i -eq $selectedIndex) {
                    $prefix = "▶ "
                    $color = "Yellow"
                }

                # Add checkbox indicators for multiple selection mode
                if ($AllowMultipleSelection -and $selectedItems -contains $i) {
                    $prefix += "☑ "
                }
                elseif ($AllowMultipleSelection) {
                    $prefix += "☐ "
                }

                # Display the menu option with proper padding and styling
                $menuLine = (" " * $menuLeftPadding) + "$prefix$($Options[$i])"
                Write-Host $menuLine -ForegroundColor $color
            }

            # Display navigation instructions based on selection mode
            Write-Host ""
            if ($AllowMultipleSelection) {
                Write-CenteredHost "Navigation: ↑/↓ arrows, Space to select/deselect, Enter to confirm, Q to quit" -ForegroundColor DarkGray
            }
            else {
                Write-CenteredHost "Navigation: ↑/↓ arrows, Enter to select, Q to quit" -ForegroundColor DarkGray
            }

            # Display module footer with version and credits
            Show-CrateFooter

            # Process keyboard input for menu navigation
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            switch ($key.VirtualKeyCode) {
                38 {
                    # Up arrow - move to previous option
                    $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $Options.Length - 1 }
                }
                40 {
                    # Down arrow - move to next option
                    $selectedIndex = if ($selectedIndex -lt ($Options.Length - 1)) { $selectedIndex + 1 } else { 0 }
                }
                32 {
                    # Space bar - toggle selection in multiple selection mode
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
                    # Enter - confirm selection and return result
                    if ($AllowMultipleSelection) {
                        return $selectedItems | ForEach-Object { $Options[$_] }
                    }
                    else {
                        return $Options[$selectedIndex]
                    }
                }
                81 {
                    # Q - quit without selection
                    return $null
                }
            }
        } while ($true)
    }
}
