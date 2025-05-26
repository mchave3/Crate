# Architecture Crate - Windows ISO Provisioning Tool

## Vue d'ensemble

Crate est un outil PowerShell moderne pour le provisioning d'images ISO Windows avec updates et language packs.

## Structure modulaire

```
Crate/
├── Core/                   # Fonctionnalités de base
│   ├── Initialize-Crate.ps1       # Initialisation, vérification admin
│   ├── Write-CrateLog.ps1          # Système de logging avancé
│   ├── Get-CrateConfig.ps1         # Gestion configuration
│   ├── Test-CrateRequirements.ps1  # Vérification prérequis
│   └── Invoke-CrateCleanup.ps1     # Nettoyage workspace
│
├── ISO/                    # Gestion des images ISO
│   ├── Mount-CrateISO.ps1          # Montage ISO
│   ├── Dismount-CrateISO.ps1       # Démontage ISO
│   ├── Get-ISOInfo.ps1             # Informations ISO
│   └── Test-ISOIntegrity.ps1       # Vérification intégrité
│
├── WIM/                    # Manipulation des fichiers WIM
│   ├── Mount-CrateWIM.ps1          # Montage WIM
│   ├── Dismount-CrateWIM.ps1       # Démontage WIM
│   ├── Get-WIMInfo.ps1             # Informations WIM
│   ├── Export-CrateWIM.ps1         # Export WIM modifié
│   └── Optimize-WIM.ps1            # Optimisation WIM
│
├── Updates/                # Gestion des mises à jour
│   ├── Get-WindowsUpdates.ps1      # Recherche updates catalog
│   ├── Download-Updates.ps1        # Téléchargement updates
│   ├── Install-Updates.ps1         # Installation dans WIM
│   ├── Test-UpdateCompatibility.ps1 # Vérification compatibilité
│   └── Remove-Updates.ps1          # Suppression updates
│
├── LanguagePacks/          # Gestion des packs de langues
│   ├── Get-LanguagePacks.ps1       # Liste language packs
│   ├── Install-LanguagePack.ps1    # Installation LP
│   ├── Remove-LanguagePack.ps1     # Suppression LP
│   └── Set-DefaultLanguage.ps1     # Langue par défaut
│
├── UI/                     # Interface utilisateur moderne
│   ├── Show-CrateMenu.ps1          # Menu principal interactif
│   ├── Show-ProgressBar.ps1        # Barres de progression
│   ├── Show-StatusTable.ps1        # Tables d'état
│   ├── Confirm-CrateAction.ps1     # Confirmations utilisateur
│   └── Write-CrateOutput.ps1       # Sortie formatée
│
├── Validation/             # Vérification et intégrité
│   ├── Test-ISOIntegrity.ps1       # Checksum ISO
│   ├── Test-WIMIntegrity.ps1       # Intégrité WIM
│   ├── Test-UpdateIntegrity.ps1    # Vérification updates
│   └── Invoke-HealthCheck.ps1      # Santé globale
│
├── Workflows/              # Orchestration des processus
│   ├── Invoke-ISOProvisioning.ps1  # Workflow principal
│   ├── Invoke-UpdateWorkflow.ps1   # Workflow updates
│   ├── Invoke-LanguageWorkflow.ps1 # Workflow langues
│   └── Resume-Workflow.ps1         # Reprise après interruption
│
└── Configuration/          # Gestion des profils
    ├── Import-CrateProfile.ps1     # Import profil
    ├── Export-CrateProfile.ps1     # Export profil
    ├── New-CrateProfile.ps1        # Création profil
    └── Get-DefaultProfile.ps1      # Profil par défaut
```

## Workspace C:/ProgramData/Crate

```
C:/ProgramData/Crate/
├── Config/                 # Configuration et profils
│   ├── settings.json
│   ├── profiles/
│   └── cache/
├── Workspace/              # Espace de travail temporaire
│   ├── ISO/               # Images ISO montées
│   ├── WIM/               # WIM en cours de traitement
│   └── Temp/              # Fichiers temporaires
├── Downloads/              # Updates et LP téléchargés
│   ├── Updates/
│   └── LanguagePacks/
├── Logs/                   # Journaux détaillés
└── Backup/                 # Sauvegardes pour rollback
```

## Workflow principal

1. **Initialisation**
   - Vérification admin
   - Création workspace
   - Chargement configuration

2. **Préparation**
   - Montage ISO source
   - Extraction WIM
   - Analyse contenu

3. **Provisioning**
   - Montage WIM
   - Installation updates/LP
   - Vérifications

4. **Finalisation**
   - Démontage WIM
   - Création ISO finale
   - Nettoyage

## Technologies

- **PowerShell 7.4+**
- **DISM** (Deployment Image Servicing and Management)
- **Spectre.Console** pour l'interface
- **Windows Update Catalog API**
- **JSON** pour la configuration
