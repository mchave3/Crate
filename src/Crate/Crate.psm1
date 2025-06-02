#region Module Header
# This psm1 is for local testing and development use only
#endregion

#region External Dependencies
# Load external assemblies/types before any other operations
try {
    if (!([System.Management.Automation.PSTypeName]'HtmlAgilityPack.HtmlDocument').Type) {
        if ($PSVersionTable.PSEdition -eq "Desktop") {
            Add-Type -Path "$PSScriptRoot\Types\Net45\HtmlAgilityPack.dll"
        } else {
            Add-Type -Path "$PSScriptRoot\Types\netstandard2.0\HtmlAgilityPack.dll"
        }
    }
} catch {
    Write-Error -Message "Failed to load HtmlAgilityPack: $_"
    throw
}
#endregion

#region Configuration and Imports
# Dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1
#endregion

#region Classes
# Load classes first explicitly before any functions that might depend on them
$classSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

try {
    $classes = @(Get-ChildItem -Path "$PSScriptRoot\Classes" @classSplat)
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
    throw 'Unable to load classes from Classes directory.'
}
#endregion

#region Private and Public Functions
# Discover all ps1 file(s) in Public and Private paths
$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

try {
    $private = @(Get-ChildItem -Path "$PSScriptRoot\Private" @itemSplat)
    $public = @(Get-ChildItem -Path "$PSScriptRoot\Public" @itemSplat)
}
catch {
    Write-Error $_
    throw 'Unable to get file information from Public/Private directories.'
}

# Dot source private functions first, then public functions
foreach ($file in $private) {
    try {
        . $file.FullName
    }
    catch {
        throw ('Unable to dot source private function {0}: {1}' -f $file.FullName, $_.Exception.Message)
    }
}

foreach ($file in $public) {
    try {
        . $file.FullName
    }
    catch {
        throw ('Unable to dot source public function {0}: {1}' -f $file.FullName, $_.Exception.Message)
    }
}
#endregion

#region Module Exports
# Export all public functions
Export-ModuleMember -Function $public.Basename

# For development/testing purposes, also export some private functions
#$privateToExport = @('Write-CrateLog', 'Initialize-Crate', 'Start-CrateOperation', 'Complete-CrateOperation', 'Write-CrateProgress', 'Get-CrateVersion', 'Test-CrateModuleUpdate')
#Export-ModuleMember -Function $privateToExport
#endregion
