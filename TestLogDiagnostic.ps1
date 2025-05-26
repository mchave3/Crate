# Test de diagnostic complet
Write-Host "=== Diagnostic Création Log ===" -ForegroundColor Cyan

# Configuration workspace
$Script:CrateWorkspace = "$env:TEMP\TestCrateWorkspace"
New-Item -Path "$Script:CrateWorkspace\Logs" -ItemType Directory -Force | Out-Null

Write-Host "Workspace configuré: $Script:CrateWorkspace" -ForegroundColor Gray

# Reset logger
$Script:CrateLogger = $null

# Test avec diagnostic
Write-Host "`nAppel de Write-CrateLog..." -ForegroundColor Yellow

# Vérification avant l'appel
Write-Host "CrateWorkspace avant: '$Script:CrateWorkspace'" -ForegroundColor Gray
Write-Host "CrateLogger avant: $($Script:CrateLogger)" -ForegroundColor Gray

Write-CrateLog -Data "Test diagnostic" -Level "Info"

# Vérification après l'appel
Write-Host "CrateLogger après: $($Script:CrateLogger -ne $null)" -ForegroundColor Gray

# Test manuel de calcul du chemin
$expectedPath = Join-Path $Script:CrateWorkspace "Logs\Crate_$(Get-Date -Format 'yyyyMMdd').log"
Write-Host "Chemin attendu: $expectedPath" -ForegroundColor Gray
Write-Host "Fichier existe: $(Test-Path $expectedPath)" -ForegroundColor Gray

# Liste des fichiers dans le dossier Logs
Write-Host "`nContenu du dossier Logs:" -ForegroundColor Yellow
Get-ChildItem (Join-Path $Script:CrateWorkspace "Logs") -Force | ForEach-Object {
    Write-Host "  📄 $($_.Name) ($(($_.Length / 1KB).ToString('F1')) KB)" -ForegroundColor Gray
}

# Test avec chemin explicite
Write-Host "`nTest direct avec même chemin..." -ForegroundColor Yellow
$directLogger = [CrateLogger]::new($expectedPath)
$directLogger.Write("Test direct", "INFO", $false, $false)
Write-Host "Fichier créé par test direct: $(Test-Path $expectedPath)" -ForegroundColor Gray

if (Test-Path $expectedPath) {
    $content = Get-Content $expectedPath
    Write-Host "Contenu complet du fichier:" -ForegroundColor Yellow
    $content | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}
