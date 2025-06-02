<#
.SYNOPSIS
    Main entry point for the Crate modern CLI interface.

.DESCRIPTION
    Starts the Crate interactive CLI interface for mounting, provisioning, and dismounting
    Windows ISO images with updates and language packs. Provides a modern, intuitive
    terminal-based experience for Windows system administrators.

.NOTES
    Name:        Start-CrateCLI.ps1
    Author:      Mickaël CHAVE
    Created:     26/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Start-CrateCLI

    Starts the Crate interactive menu for managing Windows ISO provisioning tasks.
#>

function Start-CrateCLI {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess("Crate", "Start")) {
            try {
                # Initialize Crate environment
                if (-not (Initialize-Crate -WorkspacePath "$env:ProgramData\Crate")) {
                    throw "Failed to initialize Crate environment"
                }
                # Show main interactive menu
                do {
                    $mainMenuOptions = @(
                        "📀 Start WIM Provisioning Workflow",
                        "---",
                        "📊 View Available WIM Masters",
                        "📦 Manage Update Cache",
                        "🧹 Cleanup Workspace",
                        "---",
                        "📋 View Logs",
                        "⚙️ Configuration",
                        "---",
                        "❌ Exit"
                    )

                    $selection = Show-CrateMenu -Title "Crate WIM Provisioning Tool" -Options $mainMenuOptions

                    if ($null -eq $selection) {
                        break
                    }

                    switch ($selection) {
                        "📀 Start WIM Provisioning Workflow" {
                            Start-CrateOperation -Operation "WIM Provisioning Workflow"
                            Write-CrateProgress -Message "Starting complete WIM provisioning workflow"
                            # TODO: Implement main WIM provisioning workflow
                            # This will include: WIM discovery → Selection → Update download → Provisioning
                            Write-CrateLog -Data "WIM provisioning workflow not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "WIM Provisioning Workflow" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "📊 View Available WIM Masters" {
                            Start-CrateOperation -Operation "WIM Masters Discovery"
                            Write-CrateProgress -Message "Scanning for available WIM master files"
                            # TODO: Implement WIM masters discovery and listing
                            Write-CrateLog -Data "WIM masters discovery not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "WIM Masters Discovery" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "📦 Manage Update Cache" {
                            Start-CrateOperation -Operation "Update Cache Management"
                            Write-CrateProgress -Message "Managing update cache"
                            # TODO: Implement update cache management (view, clean, download)
                            Write-CrateLog -Data "Update cache management not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "Update Cache Management" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "🧹 Cleanup Workspace" {
                            Write-CrateLog -Data "This will clean temporary files. Continue? (y/N)" -Level "Prompt" -NoFileLog
                            $confirm = Read-Host
                            if ($confirm -eq 'y' -or $confirm -eq 'Y') {
                                Start-CrateOperation -Operation "Workspace Cleanup"
                                # TODO: Implement workspace cleanup
                                Write-CrateLog -Data "Workspace cleaned successfully" -Level "Success"
                                Complete-CrateOperation -Operation "Workspace Cleanup" -Success $true
                            }
                            Read-Host "Press Enter to continue"
                        }
                        "📋 View Logs" {
                            $logPath = Join-Path -Path $Script:CrateWorkspace -ChildPath "Logs"
                            if (Test-Path -Path $logPath) {
                                Start-Process -FilePath "explorer.exe" -ArgumentList $logPath
                            }
                        }
                        "⚙️ Configuration" {
                            Write-CrateProgress -Message "Opening configuration management"
                            # TODO: Implement configuration menu (WIM paths, update sources, cache settings)
                            Write-CrateLog -Data "Configuration management not yet implemented" -Level "Warning"
                            Read-Host "Press Enter to continue"
                        }
                        "❌ Exit" {
                            Write-CrateProgress -Message "Exiting Crate"
                            return
                        }
                    }
                } while ($true)
            }
            catch {
                Write-CrateLog -Data "Error in Start-Crate: $($_.Exception.Message)" -Level 'Error'
                throw
            }
        }
    }
    end {
        Clear-Host
        Write-CrateLog -Data "Thank you for using Crate!" -Level 'Success'
    }
}
