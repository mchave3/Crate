# Script de test pour vérifier la création du fichier de log Crate
# Test Log Creation - Crate Project

Write-Host "=== Test de création du fichier de log Crate ===" -ForegroundColor Cyan

# Import du module Crate
try {
    Write-Host "1. Import du module Crate..." -ForegroundColor Yellow
    Import-Module "e:\Crate\src\Crate\Crate.psm1" -Force
    Write-Host "   ✅ Module importé avec succès" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Erreur lors de l'import du module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 1: Vérification de la classe CrateLogger
Write-Host "`n2. Test de la classe CrateLogger..." -ForegroundColor Yellow
try {
    $testLogPath = "$env:TEMP\TestCrateLogger_$(Get-Date -Format 'yyyyMMddHHmmss').log"
    $logger = [CrateLogger]::new($testLogPath)

    Write-Host "   ✅ Instance CrateLogger créée" -ForegroundColor Green
    Write-Host "   📁 Chemin du log: $testLogPath" -ForegroundColor Gray
      # Test écriture
    $logger.Write("Test message from CrateLogger", "INFO", $false, $false)

    if (Test-Path $testLogPath) {
        Write-Host "   ✅ Fichier de log créé avec succès" -ForegroundColor Green
        $content = Get-Content $testLogPath
        Write-Host "   📝 Contenu: $content" -ForegroundColor Gray
    }
    else {
        Write-Host "   ❌ Fichier de log non créé" -ForegroundColor Red
    }
}
catch {
    Write-Host "   ❌ Erreur lors du test de CrateLogger: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérification avec Write-CrateLog sans workspace
Write-Host "`n3. Test de Write-CrateLog sans workspace..." -ForegroundColor Yellow
try {
    # Reset du logger script pour forcer une nouvelle initialisation
    $Script:CrateLogger = $null
    $Script:CrateWorkspace = $null

    Write-CrateLog -Data "Test message sans workspace" -Level "Info"

    # Vérifier où le fichier a été créé
    $expectedPath = "$env:TEMP\Crate_$(Get-Date -Format 'yyyyMMdd').log"
    if (Test-Path $expectedPath) {
        Write-Host "   ✅ Fichier de log créé dans TEMP: $expectedPath" -ForegroundColor Green
        $content = Get-Content $expectedPath -Tail 1
        Write-Host "   📝 Dernière ligne: $content" -ForegroundColor Gray
    }
    else {
        Write-Host "   ❌ Fichier de log non trouvé dans TEMP" -ForegroundColor Red
        Write-Host "   🔍 Vérification des fichiers dans TEMP..." -ForegroundColor Yellow
        Get-ChildItem "$env:TEMP\Crate_*.log" | ForEach-Object {
            Write-Host "   📄 Trouvé: $($_.FullName)" -ForegroundColor Gray
        }
    }
}
catch {
    Write-Host "   ❌ Erreur lors du test Write-CrateLog: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Initialisation complète avec workspace
Write-Host "`n4. Test avec Initialize-Crate..." -ForegroundColor Yellow
try {
    # Reset des variables
    $Script:CrateLogger = $null
    $Script:CrateWorkspace = $null
    $Script:CrateInitialized = $false

    # Test workspace temporaire
    $testWorkspace = "$env:TEMP\CrateTestWorkspace_$(Get-Date -Format 'yyyyMMddHHmmss')"

    Write-Host "   🔧 Initialisation avec workspace: $testWorkspace" -ForegroundColor Gray

    # On va simuler l'initialisation sans les privilèges admin
    # Créer manuellement la structure workspace
    $workspaceStructure = @(
        'Config',
        'Config\profiles',
        'Config\cache',
        'Workspace',
        'Workspace\ISO',
        'Workspace\WIM',
        'Workspace\Temp',
        'Downloads',
        'Downloads\Updates',
        'Downloads\LanguagePacks',
        'Logs',
        'Backup'
    )

    foreach ($folder in $workspaceStructure) {
        $fullPath = Join-Path $testWorkspace $folder
        if (-not (Test-Path $fullPath)) {
            New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
        }
    }

    # Définir le workspace
    $Script:CrateWorkspace = $testWorkspace

    # Test de logging avec workspace
    Write-CrateLog -Data "Test message avec workspace configuré" -Level "Info"

    $expectedLogPath = Join-Path $testWorkspace "Logs\Crate_$(Get-Date -Format 'yyyyMMdd').log"
    if (Test-Path $expectedLogPath) {
        Write-Host "   ✅ Fichier de log créé dans workspace: $expectedLogPath" -ForegroundColor Green
        $content = Get-Content $expectedLogPath -Tail 1
        Write-Host "   📝 Dernière ligne: $content" -ForegroundColor Gray
    }
    else {
        Write-Host "   ❌ Fichier de log non trouvé dans workspace" -ForegroundColor Red
        Write-Host "   📁 Dossier Logs existe: $(Test-Path (Join-Path $testWorkspace 'Logs'))" -ForegroundColor Gray
    }
}
catch {
    Write-Host "   ❌ Erreur lors du test avec workspace: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   📋 Détails de l'erreur: $($_.Exception.StackTrace)" -ForegroundColor Red
}

# Test 4: Vérification des permissions
Write-Host "`n5. Test des permissions de fichier..." -ForegroundColor Yellow
try {
    $testPermissionPath = "$env:TEMP\CratePermissionTest_$(Get-Date -Format 'yyyyMMddHHmmss').log"

    # Test de création direct
    "Test permission" | Out-File -FilePath $testPermissionPath -Encoding UTF8

    if (Test-Path $testPermissionPath) {
        Write-Host "   ✅ Permissions OK pour création de fichier dans TEMP" -ForegroundColor Green
        Remove-Item $testPermissionPath -Force
    }
    else {
        Write-Host "   ❌ Problème de permissions dans TEMP" -ForegroundColor Red
    }

    # Test dans le dossier Crate potentiel
    $cratePath = "C:\ProgramData\Crate\Logs"
    if (Test-Path $cratePath) {
        $testCratePath = Join-Path $cratePath "PermissionTest_$(Get-Date -Format 'yyyyMMddHHmmss').log"
        try {
            "Test permission Crate" | Out-File -FilePath $testCratePath -Encoding UTF8
            if (Test-Path $testCratePath) {
                Write-Host "   ✅ Permissions OK pour écriture dans Crate Logs" -ForegroundColor Green
                Remove-Item $testCratePath -Force
            }
        }
        catch {
            Write-Host "   ⚠️  Problème de permissions dans Crate Logs: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "   ℹ️  Dossier Crate Logs n'existe pas encore" -ForegroundColor Blue
    }
}
catch {
    Write-Host "   ❌ Erreur lors du test de permissions: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Fin des tests ===" -ForegroundColor Cyan
Write-Host "💡 Conseil: Exécutez 'Start-Crate' pour une initialisation complète" -ForegroundColor Yellow
