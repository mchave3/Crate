# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

#region External Dependencies
# Load external assemblies/types before any other operations
try {
    if (!([System.Management.Automation.PSTypeName]'HtmlAgilityPack.HtmlDocument').Type) {
        if ($PSVersionTable.PSEdition -eq "Desktop") {
            Add-Type -Path "$PSScriptRoot\Types\Net45\HtmlAgilityPack.dll"
        }
        else {
            Add-Type -Path "$PSScriptRoot\Types\netstandard2.0\HtmlAgilityPack.dll"
        }
    }
}
catch {
    Write-Error -Message "Failed to load HtmlAgilityPack: $_"
    throw
}
#endregion

# region script variables
# $script:resourcePath = "$PSScriptRoot\Resources"
