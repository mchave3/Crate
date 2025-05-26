# Test simple de création de fichier de log
Write-Host "=== Test Simple Log Creation ===" -ForegroundColor Cyan

# Test 1: Workspace configuré
Write-Host "`n1. Configuration avec workspace..." -ForegroundColor Yellow
$Script:CrateWorkspace = "$env:TEMP\TestCrateWorkspace"
New-Item -Path "$Script:CrateWorkspace\Logs" -ItemType Directory -Force | Out-Null

Write-Host "   Workspace configuré: $Script:CrateWorkspace" -ForegroundColor Gray

# Reset le logger pour forcer une nouvelle initialisation
$Script:CrateLogger = $null

# Test d'écriture
Write-CrateLog -Data "Test avec workspace configuré" -Level "Info"

# Vérification
$expectedLogPath = Join-Path $Script:CrateWorkspace "Logs\Crate_$(Get-Date -Format 'yyyyMMdd').log"
if (Test-Path $expectedLogPath) {
    Write-Host "   ✅ Fichier créé: $expectedLogPath" -ForegroundColor Green
    $content = Get-Content $expectedLogPath -Tail 1
    Write-Host "   📝 Contenu: $content" -ForegroundColor Gray
} else {
    Write-Host "   ❌ Fichier non créé: $expectedLogPath" -ForegroundColor Red
    Write-Host "   🔍 Vérification du dossier Logs..." -ForegroundColor Yellow
    Get-ChildItem (Join-Path $Script:CrateWorkspace "Logs") -Force | ForEach-Object {
        Write-Host "   📄 Trouvé: $($_.Name)" -ForegroundColor Gray
    }
}

# Test 2: Sans workspace
Write-Host "`n2. Test sans workspace..." -ForegroundColor Yellow
$Script:CrateWorkspace = $null
$Script:CrateLogger = $null

Write-CrateLog -Data "Test sans workspace" -Level "Info"

$expectedTempPath = "$env:TEMP\Crate_$(Get-Date -Format 'yyyyMMdd').log"
if (Test-Path $expectedTempPath) {
    Write-Host "   ✅ Fichier créé dans TEMP: $expectedTempPath" -ForegroundColor Green
    $content = Get-Content $expectedTempPath -Tail 1
    Write-Host "   📝 Contenu: $content" -ForegroundColor Gray
} else {
    Write-Host "   ❌ Fichier non créé dans TEMP" -ForegroundColor Red
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Cyan
