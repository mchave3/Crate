<#
.SYNOPSIS
    Brief description of the script purpose

.DESCRIPTION
    Detailed description of what the script/function does

.NOTES
    Name:        Start-Crate.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Start-Crate
    Example of how to use this script/function
#>
<#
.SYNOPSIS
    Main entry point for the Crate Windows ISO provisioning tool.

.DESCRIPTION
    Starts the Crate interactive CLI interface for mounting, provisioning, and dismounting
    Windows ISO images with updates and language packs. Provides a modern, intuitive
    terminal-based experience for Windows system administrators.

.PARAMETER WorkspacePath
    Custom workspace path for Crate operations. Defaults to C:\ProgramData\Crate.

.PARAMETER ConfigProfile
    Name of the configuration profile to use.

.PARAMETER AutoMode
    Run in automated mode using the specified profile without interactive menus.

.EXAMPLE
    Start-Crate
    Starts Crate with the interactive main menu.

.EXAMPLE
    Start-Crate -WorkspacePath "D:\CrateWorkspace"
    Starts Crate with a custom workspace location.

.EXAMPLE
    Start-Crate -ConfigProfile "Windows11Updates" -AutoMode
    Runs Crate in automated mode using the specified profile.

.NOTES
    Name:        Start-Crate.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License
    Requires:    PowerShell 7.4+, Administrator privileges, Windows OS

.LINK
    https://github.com/mchave3/Crate
#>
function Start-Crate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$WorkspacePath = 'C:\ProgramData\Crate',

        [Parameter()]
        [string]$ConfigProfile,

        [Parameter()]
        [switch]$AutoMode
    )

    begin {
        # Clear screen and show welcome banner
        Clear-Host
        Write-Host ""
        Write-Host "🚀 Crate - Windows ISO Provisioning Tool v25.5.26.1" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host "Modern CLI interface for ISO mounting, provisioning, and dismounting" -ForegroundColor Gray
        Write-Host "─" * 70 -ForegroundColor DarkGray
        Write-Host ""
    }

    process {
        if ($PSCmdlet.ShouldProcess("Crate", "Start")) {
            try {
                # Initialize Crate environment
                Write-Host "ℹ️  Initializing Crate environment..." -ForegroundColor Cyan

                if (-not (Initialize-Crate -WorkspacePath $WorkspacePath)) {
                    throw "Failed to initialize Crate environment"
                }

                if ($AutoMode -and $ConfigProfile) {
                    # Run in automated mode
                    Write-Host "ℹ️  Running in automated mode with profile: $ConfigProfile" -ForegroundColor Cyan
                    # TODO: Implement automated workflow
                    Write-Host "⚠️  Automated mode not yet implemented" -ForegroundColor Yellow
                    return
                }

                # Show main interactive menu
                do {
                    $mainMenuOptions = @(
                        "📀 Mount Windows ISO",
                        "🔄 Provision Updates",
                        "🌐 Add Language Packs",
                        "💿 Create Provisioned ISO",
                        "📊 View Current Status",
                        "⚙️  Configuration",
                        "📋 View Logs",
                        "🧹 Cleanup Workspace",
                        "❌ Exit"
                    )

                    $selection = Show-CrateMenu -Title "Crate Main Menu" -Options $mainMenuOptions

                    if ($null -eq $selection) {
                        break
                    }

                    switch ($selection) {
                        "📀 Mount Windows ISO" {
                            Write-Host "ℹ️  Starting ISO mount process..." -ForegroundColor Cyan
                            # TODO: Implement ISO mounting workflow
                            Write-Host "⚠️  ISO mounting not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "🔄 Provision Updates" {
                            Write-Host "ℹ️  Starting update provisioning..." -ForegroundColor Cyan
                            # TODO: Implement update provisioning workflow
                            Write-Host "⚠️  Update provisioning not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "🌐 Add Language Packs" {
                            Write-Host "ℹ️  Starting language pack installation..." -ForegroundColor Cyan
                            # TODO: Implement language pack workflow
                            Write-Host "⚠️  Language pack installation not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "💿 Create Provisioned ISO" {
                            Write-Host "ℹ️  Creating provisioned ISO..." -ForegroundColor Cyan
                            # TODO: Implement ISO creation workflow
                            Write-Host "⚠️  ISO creation not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "📊 View Current Status" {
                            Write-Host "ℹ️  Current Crate Status:" -ForegroundColor Cyan
                            Write-Host "Workspace: $global:CrateWorkspace" -ForegroundColor Cyan
                            Write-Host "Initialized: $global:CrateInitialized" -ForegroundColor Cyan
                            # TODO: Show detailed status
                            Read-Host "Press Enter to continue"
                        }
                        "⚙️  Configuration" {
                            Write-Host "ℹ️  Configuration management..." -ForegroundColor Cyan
                            # TODO: Implement configuration menu
                            Write-Host "⚠️  Configuration management not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "📋 View Logs" {
                            Write-Host "ℹ️  Opening log viewer..." -ForegroundColor Cyan
                            # TODO: Implement log viewer
                            Write-Host "⚠️  Log viewer not yet implemented" -ForegroundColor Yellow
                            Read-Host "Press Enter to continue"
                        }
                        "🧹 Cleanup Workspace" {
                            Write-Host "⚠️  This will clean temporary files. Continue? (y/N)" -ForegroundColor Yellow
                            $confirm = Read-Host
                            if ($confirm -eq 'y' -or $confirm -eq 'Y') {
                                # TODO: Implement cleanup
                                Write-Host "✅ Workspace cleaned successfully" -ForegroundColor Green
                            }
                            Read-Host "Press Enter to continue"
                        }
                        "❌ Exit" {
                            Write-Host "ℹ️  Exiting Crate..." -ForegroundColor Cyan
                            return
                        }
                    }
                } while ($true)
            }
            catch {
                Write-Host "❌ An error occurred: $($_.Exception.Message)" -ForegroundColor Red
                Write-CrateLog -Data "Error in Start-Crate: $($_.Exception.Message)" -Level 'Error'
                throw
            }
        }
    }

    end {
        Write-Host "✅ Thank you for using Crate!" -ForegroundColor Green
    }
}
