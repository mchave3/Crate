# this psm1 is for local testing and development use only

# dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# Load classes first explicitly
$classSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

try {
    $classes = @(Get-ChildItem -Path "$PSScriptRoot\Classes" @classSplat)
    # Load all classes first
    foreach ($class in $classes) {
        try {
            . $class.FullName
        }
        catch {
            throw ('Unable to dot source class {0}: {1}' -f $class.FullName, $_.Exception.Message)
        }
    }
}
catch {
    Write-Error $_
    throw 'Unable to load classes from Classes src.'
}

# discover all ps1 file(s) in Public and Private paths
$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}
try {
    $public = @(Get-ChildItem -Path "$PSScriptRoot\Public" @itemSplat)
    $private = @(Get-ChildItem -Path "$PSScriptRoot\Private" @itemSplat)
}
catch {
    Write-Error $_
    throw 'Unable to get get file information from Public/Private src.'
}

# dot source all function files after classes are loaded
foreach ($file in @($private + $public)) {
    try {
        . $file.FullName
    }
    catch {
        throw ('Unable to dot source {0}: {1}' -f $file.FullName, $_.Exception.Message)
    }
}

# export all public functions
Export-ModuleMember -Function $public.Basename

# For development/testing purposes, also export some private functions
$privateToExport = @('Write-CrateLog', 'Initialize-Crate', 'Start-CrateOperation', 'Complete-CrateOperation', 'Write-CrateProgress')
Export-ModuleMember -Function $privateToExport
