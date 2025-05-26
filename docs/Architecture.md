# Crate Architecture - Windows ISO Provisioning Tool

## Overview

Crate is a modern PowerShell tool for provisioning Windows ISO images with updates and language packs.

## Modular Structure

```text
Crate/
├── Core/                   # Core functionalities
│   ├── Initialize-Crate.ps1       # Initialization, admin verification
│   ├── Write-CrateLog.ps1          # Advanced logging system
│   ├── Get-CrateConfig.ps1         # Configuration management
│   ├── Test-CrateRequirement.ps1  # Prerequisites verification
│   └── Invoke-CrateCleanup.ps1     # Workspace cleanup
│
├── ISO/                    # ISO image management
│   ├── Mount-CrateISO.ps1          # ISO mounting
│   ├── Dismount-CrateISO.ps1       # ISO dismounting
│   ├── Get-ISOInfo.ps1             # ISO information
│   └── Test-ISOIntegrity.ps1       # Integrity verification
│
├── WIM/                    # WIM file manipulation
│   ├── Mount-CrateWIM.ps1          # WIM mounting
│   ├── Dismount-CrateWIM.ps1       # WIM dismounting
│   ├── Get-WIMInfo.ps1             # WIM information
│   ├── Export-CrateWIM.ps1         # Modified WIM export
│   └── Optimize-WIM.ps1            # WIM optimization
│
├── Updates/                # Update management
│   ├── Get-WindowsUpdates.ps1      # Catalog update search
│   ├── Download-Updates.ps1        # Update downloads
│   ├── Install-Updates.ps1         # WIM installation
│   ├── Test-UpdateCompatibility.ps1 # Compatibility verification
│   └── Remove-Updates.ps1          # Update removal
│
├── LanguagePacks/          # Language pack management
│   ├── Get-LanguagePacks.ps1       # Language pack listing
│   ├── Install-LanguagePack.ps1    # LP installation
│   ├── Remove-LanguagePack.ps1     # LP removal
│   └── Set-DefaultLanguage.ps1     # Default language
│
├── UI/                     # Modern user interface
│   ├── Show-CrateMenu.ps1          # Interactive main menu
│   ├── Show-ProgressBar.ps1        # Progress bars
│   ├── Show-StatusTable.ps1        # Status tables
│   ├── Confirm-CrateAction.ps1     # User confirmations
│   └── Write-CrateOutput.ps1       # Formatted output
│
├── Validation/             # Verification and integrity
│   ├── Test-ISOIntegrity.ps1       # ISO checksum
│   ├── Test-WIMIntegrity.ps1       # WIM integrity
│   ├── Test-UpdateIntegrity.ps1    # Update verification
│   └── Invoke-HealthCheck.ps1      # Global health
│
├── Workflows/              # Process orchestration
│   ├── Invoke-ISOProvisioning.ps1  # Main workflow
│   ├── Invoke-UpdateWorkflow.ps1   # Update workflow
│   ├── Invoke-LanguageWorkflow.ps1 # Language workflow
│   └── Resume-Workflow.ps1         # Resume after interruption
│
└── Configuration/          # Profile management
    ├── Import-CrateProfile.ps1     # Profile import
    ├── Export-CrateProfile.ps1     # Profile export
    ├── New-CrateProfile.ps1        # Profile creation
    └── Get-DefaultProfile.ps1      # Default profile
```

## Workspace C:/ProgramData/Crate

```text
C:/ProgramData/Crate/
├── Config/                 # Configuration and profiles
│   ├── settings.json
│   ├── profiles/
│   └── cache/
├── Workspace/              # Temporary workspace
│   ├── ISO/               # Mounted ISO images
│   ├── WIM/               # WIM files being processed
│   └── Temp/              # Temporary files
├── Downloads/              # Downloaded updates and LPs
│   ├── Updates/
│   └── LanguagePacks/
├── Logs/                   # Detailed logs
└── Backup/                 # Backups for rollback
```

## Main Workflow

1. **Initialization**
   - Admin verification
   - Workspace creation
   - Configuration loading

2. **Preparation**
   - Source ISO mounting
   - WIM extraction
   - Content analysis

3. **Provisioning**
   - WIM mounting
   - Updates/LP installation
   - Verifications

4. **Finalization**
   - WIM dismounting
   - Final ISO creation
   - Cleanup

## Technologies

- **PowerShell 7.4+**
- **DISM** (Deployment Image Servicing and Management)
- **Spectre.Console** for interface
- **Windows Update Catalog API**
- **JSON** for configuration
