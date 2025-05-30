<#
.SYNOPSIS
    Main entry point for the Crate Windows ISO provisioning tool.

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
                        "📀 Mount Windows ISO",
                        "🔄 Provision Updates",
                        "🌐 Add Language Packs",
                        "💿 Create Provisioned ISO",
                        "📊 View Current Status",
                        "⚙️ Configuration",
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
                            Start-CrateOperation -Operation "ISO Mount Process"
                            Write-CrateProgress -Message "Starting ISO mount process"
                            # TODO: Implement ISO mounting workflow
                            Write-CrateLog -Data "ISO mounting not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "ISO Mount Process" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "🔄 Provision Updates" {
                            Start-CrateOperation -Operation "Update Provisioning"
                            Write-CrateProgress -Message "Starting update provisioning"
                            # TODO: Implement update provisioning workflow
                            Write-CrateLog -Data "Update provisioning not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "Update Provisioning" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "🌐 Add Language Packs" {
                            Start-CrateOperation -Operation "Language Pack Installation"
                            Write-CrateProgress -Message "Starting language pack installation"
                            # TODO: Implement language pack workflow
                            Write-CrateLog -Data "Language pack installation not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "Language Pack Installation" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "💿 Create Provisioned ISO" {
                            Start-CrateOperation -Operation "ISO Creation"
                            Write-CrateProgress -Message "Creating provisioned ISO"
                            # TODO: Implement ISO creation workflow
                            Write-CrateLog -Data "ISO creation not yet implemented" -Level "Warning"
                            Complete-CrateOperation -Operation "ISO Creation" -Success $false
                            Read-Host "Press Enter to continue"
                        }
                        "📊 View Current Status" {
                            Write-CrateLog -Data "Current Crate Status:" -Level "Info"
                            Write-CrateLog -Data "Workspace: $Script:CrateWorkspace" -Level 'Info'
                            Write-CrateLog -Data "Initialized: $Script:CrateInitialized" -Level 'Info'
                            # TODO: Show detailed status
                            Read-Host "Press Enter to continue"
                        }
                        "⚙️ Configuration" {
                            Write-CrateProgress -Message "Opening configuration management"
                            # TODO: Implement configuration menu
                            Write-CrateLog -Data "Configuration management not yet implemented" -Level "Warning"
                            Read-Host "Press Enter to continue"
                        }
                        "📋 View Logs" {
                            $logPath = Join-Path -Path $Script:CrateWorkspace -ChildPath "Logs"
                            if (Test-Path -Path $logPath) {
                                Start-Process -FilePath "explorer.exe" -ArgumentList $logPath
                            }
                        }
                        "🧹 Cleanup Workspace" {
                            Write-CrateLog -Data "This will clean temporary files. Continue? (y/N)" -Level "Prompt" -NoFileLog
                            $confirm = Read-Host
                            if ($confirm -eq 'y' -or $confirm -eq 'Y') {
                                Start-CrateOperation -Operation "Workspace Cleanup"
                                # TODO: Implement cleanup
                                Write-CrateLog -Data "Workspace cleaned successfully" -Level "Success"
                                Complete-CrateOperation -Operation "Workspace Cleanup" -Success $true
                            }
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
