<#
.SYNOPSIS
    Searches and retrieves Microsoft Update Catalog updates with advanced filtering

.DESCRIPTION
    This function searches the Microsoft Update Catalog for updates based on various criteria.
    It supports filtering by operating system, architecture, update type, date ranges, and more.
    Results can be formatted in multiple output formats and sorted by different fields.

.NOTES
    Name:        Get-CrateMSCatalogUpdate.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Get-CrateMSCatalogUpdate -Search "Windows 10"
    Searches for Windows 10 updates in the Microsoft Update Catalog

.EXAMPLE
    Get-CrateMSCatalogUpdate -OperatingSystem "Windows 11" -Version "22H2" -UpdateType "Cumulative Updates"
    Searches for Windows 11 22H2 cumulative updates
#>
function Get-CrateMSCatalogUpdate {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([MSCatalogUpdate[]])]
    param (
        #region Parameters
        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates by architecture")]
        [ValidateSet("All", "x64", "x86", "arm64")]
        [string] $Architecture = "All",

        [Parameter(Mandatory = $false,
            HelpMessage = "Sort in descending order")]
        [switch] $Descending,

        [Parameter(Mandatory = $false,
            HelpMessage = "Exclude .NET Framework updates")]
        [switch] $ExcludeFramework,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates from this date")]
        [DateTime] $FromDate,

        [Parameter(Mandatory = $false,
            HelpMessage = "Format for the results")]
        [ValidateSet("Default", "CSV", "JSON", "XML")]
        [string] $Format = "Default",

        [Parameter(Mandatory = $false,
            HelpMessage = "Only show .NET Framework updates")]
        [switch] $GetFramework,

        [Parameter(Mandatory = $false,
            HelpMessage = "Search through all available pages")]
        [switch] $AllPages,

        [Parameter(Mandatory = $false,
            HelpMessage = "Include dynamic updates")]
        [switch] $IncludeDynamic,

        [Parameter(Mandatory = $false,
            HelpMessage = "Include file names in the results")]
        [switch] $IncludeFileNames,

        [Parameter(Mandatory = $false,
            HelpMessage = "Include preview updates")]
        [switch] $IncludePreview,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates from the last N days")]
        [int] $LastDays,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates with maximum size")]
        [double] $MaxSize,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates with minimum size")]
        [double] $MinSize,

        [Parameter(Mandatory = $true, ParameterSetName = 'OS',
            HelpMessage = "Operating System to search updates for")]
        [ValidateSet("Windows 11", "Windows 10", "Windows Server")]
        [string] $OperatingSystem,

        [Parameter(Mandatory = $false,
            HelpMessage = "Select specific properties to display")]
        [string[]] $Properties,

        [Parameter(Mandatory = $true, ParameterSetName = 'Search',
            Position = 0,
            HelpMessage = "Search query for Microsoft Update Catalog")]
        [string] $Search,

        [Parameter(Mandatory = $false,
            HelpMessage = "Unit for size filtering (MB or GB)")]
        [ValidateSet("MB", "GB")]
        [string] $SizeUnit = "MB",

        [Parameter(Mandatory = $false,
            HelpMessage = "Sort results by specified field")]
        [ValidateSet("Date", "Size", "Title", "Classification", "Product")]
        [string] $SortBy = "Date",

        [Parameter(Mandatory = $false,
            HelpMessage = "Use strict search with exact phrase matching")]
        [switch] $Strict,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter updates until this date")]
        [DateTime] $ToDate,

        [Parameter(Mandatory = $false,
            HelpMessage = "Filter by update type")]
        [ValidateSet(
            "Security Updates",
            "Updates",
            "Critical Updates",
            "Feature Packs",
            "Service Packs",
            "Tools",
            "Update Rollups",
            "Cumulative Updates",
            "Security Quality Updates",
            "Driver Updates"
        )]
        [string[]] $UpdateType,

        [Parameter(Mandatory = $false, ParameterSetName = 'OS',
            HelpMessage = "OS Version/Release (e.g., 22H2, 21H2, 23H2)")]
        [string] $Version
        #endregion Parameters
    )

    begin {
        #region Initialization
        Start-CrateOperation -Operation "Microsoft Catalog Update Search"
        Write-CrateLog -Data "Starting Microsoft Catalog update search" -Level "Info"

        # Ensure MSCatalogUpdate class is available
        if (-not ('MSCatalogUpdate' -as [type])) {
            $classPath = Join-Path $PSScriptRoot '..\Classes\MSCatalogUpdate.Class.ps1'
            if (Test-Path $classPath) {
                . $classPath
            }
            else {
                Write-CrateLog -Data "MSCatalogUpdate class file not found at: $classPath" -Level "Error"
                throw "MSCatalogUpdate class file not found at: $classPath"
            }
        }

        $ProgressPreference = "SilentlyContinue"
        $Updates = @()
        $MaxResults = 1000
        #endregion Initialization

        #region Query Building
        Write-CrateProgress -Message "Building search query"
        # Build search query based on parameters
        $searchQuery = if ($PSCmdlet.ParameterSetName -eq 'OS') {
            switch ($OperatingSystem) {
                "Windows 10" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 10 Version $Version"
                        }
                        else {
                            "Windows 10 Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 10"
                        }
                        else {
                            "Windows 10"
                        }
                    }
                }
                "Windows 11" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 11 Version $Version"
                        }
                        else {
                            "Windows 11 Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Windows 11"
                        }
                        else {
                            "Windows 11"
                        }
                    }
                }
                "Windows Server" {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Microsoft Server Operating System, Version $Version"
                        }
                        else {
                            "Microsoft Server Operating System, Version $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for Microsoft Server Operating System"
                        }
                        else {
                            "Microsoft Server Operating System"
                        }
                    }
                }
                default {
                    if ($Version) {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for $OperatingSystem $Version"
                        }
                        else {
                            "$OperatingSystem $Version"
                        }
                    }
                    else {
                        if ($UpdateType -contains "Cumulative Updates") {
                            "Cumulative Update for $OperatingSystem"
                        }
                        else {
                            "$OperatingSystem"
                        }
                    }
                }
            }
        }
        else {
            $Search
        }

        Write-Verbose "Search query: $searchQuery"
        Write-CrateLog -Data "Search query: $searchQuery" -Level "Debug"
        #endregion Query Building
    }

    process {
        try {
            #region Search Preparation
            Write-CrateProgress -Message "Preparing search request"
            # Prepare search query
            $EncodedSearch = switch ($true) {
                $Strict { [uri]::EscapeDataString('"' + $searchQuery + '"') }
                $GetFramework { [uri]::EscapeDataString("*$searchQuery*") }
                default { [uri]::EscapeDataString($searchQuery) }
            }

            # Initialize catalog request
            $Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$EncodedSearch"
            Write-CrateLog -Data "Sending request to Microsoft Update Catalog" -Level "Debug"
            $Res = Invoke-CrateCatalogRequest -Uri $Uri
            $Rows = $Res.Rows
            #endregion Search Preparation

            #region Pagination
            # Handle pagination
            if ($AllPages) {
                Write-CrateProgress -Message "Processing multiple result pages"
                $PageCount = 0
                # Microsoft Catalog limit is 40 pages
                while ($Res.NextPage -and $PageCount -lt 39) {
                    $PageCount++
                    Write-CrateLog -Data "Fetching result page $PageCount" -Level "Debug"
                    $PageUri = "$Uri&p=$PageCount"
                    $Res = Invoke-CrateCatalogRequest -Uri $PageUri
                    $Rows += $Res.Rows
                }
                Write-CrateLog -Data "Retrieved $PageCount additional pages of results" -Level "Debug"
            }
            #endregion Pagination

            #region Base Filtering
            Write-CrateProgress -Message "Filtering update results"
            # Apply base filters with improved logic
            $Rows = $Rows.Where({
                    $title = $_.SelectNodes("td")[1].InnerText.Trim()
                    $classification = $_.SelectNodes("td")[3].InnerText.Trim()
                    $include = $true

                    # Basic exclusion filters
                    if (-not $IncludeDynamic -and $title -like "*Dynamic*") { $include = $false }
                    if (-not $IncludePreview -and $title -like "*Preview*") { $include = $false }

                    # Framework filtering: handle GetFramework and ExcludeFramework parameters
                    if ($GetFramework) {
                        # If GetFramework is specified, only keep Framework updates
                        if (-not ($title -like "*Framework*")) { $include = $false }
                    }
                    elseif ($ExcludeFramework) {
                        # If ExcludeFramework is specified, exclude Framework updates
                        if ($title -like "*Framework*") { $include = $false }
                    }

                    # OS and Version specific filtering
                    if ($PSCmdlet.ParameterSetName -eq 'OS') {
                        if ($OperatingSystem -eq "Windows Server") {
                            # For Server, look for "Microsoft server" or similar patterns
                            if (-not ($title -like "*Microsoft*Server*" -or $title -like "*Server Operating System*")) { $include = $false }
                        }
                        else {
                            # For other OS types, use the standard pattern
                            if (-not ($title -like "*$OperatingSystem*")) { $include = $false }
                        }
                        if ($Version -and -not ($title -like "*$Version*")) { $include = $false }
                    }

                    # Update type filtering
                    if ($UpdateType) {
                        $hasMatchingType = $false
                        foreach ($type in $UpdateType) {
                            switch ($type) {
                                "Security Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Security Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Cumulative Updates" {
                                    # In the title, look for "Cumulative Update"
                                    if ($title -like "*Cumulative Update*") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Critical Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Critical Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Updates" {
                                    # In the Classification column
                                    if ($classification -eq "Updates") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Feature Packs" {
                                    # In the Classification column
                                    if ($classification -eq "Feature Packs") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Service Packs" {
                                    # In the Classification column
                                    if ($classification -eq "Service Packs") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Tools" {
                                    # In the Classification column
                                    if ($classification -eq "Tools") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Update Rollups" {
                                    # In the Classification column
                                    if ($classification -eq "Update Rollups") {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Security Quality Updates" {
                                    # Combines security and quality
                                    if (($classification -eq "Security Updates") -and
                                        ($title -like "*Quality Update*")) {
                                        $hasMatchingType = $true
                                    }
                                }
                                "Driver Updates" {
                                    # For drivers
                                    if ($title -like "*Driver*") {
                                        $hasMatchingType = $true
                                    }
                                }
                                default {
                                    if ($title -like "*$type*") {
                                        $hasMatchingType = $true
                                    }
                                }
                            }
                            if ($hasMatchingType) { break }
                        }
                        if (-not $hasMatchingType) { $include = $false }
                    }

                    $include
                })
            #endregion Base Filtering

            #region Architecture Filtering
            # Apply architecture filter with improved logic
            if ($Architecture -ne "all") {
                $Rows = $Rows.Where({
                        $title = $_.SelectNodes("td")[1].InnerText.Trim()
                        switch ($Architecture) {
                            "x64" { $title -match "x64|64.?bit|64.?based" -and -not ($title -match "x86|32.?bit|arm64") }
                            "x86" { $title -match "x86|32.?bit|32.?based" -and -not ($title -match "64.?bit|arm64") }
                            "arm64" { $title -match "arm64|ARM.?based" }
                        }
                    })
            }
            #endregion Architecture Filtering

            #region Create Update Objects
            Write-CrateProgress -Message "Creating update objects"
            # Create MSCatalogUpdate objects with improved error handling
            $Updates = $Rows.Where({ $_.Id -ne "headerRow" }).ForEach({
                    try {
                        [MSCatalogUpdate]::new($_, $IncludeFileNames)
                    }
                    catch {
                        Write-CrateLog -Data "Failed to process update: $($_.Exception.Message)" -Level "Warning"
                        $null
                    }
                }) | Where-Object { $null -ne $_ }
            #endregion Create Update Objects

            #region Apply Filters
            # Apply date filters
            if ($FromDate) { $Updates = $Updates.Where({ $_.LastUpdated -ge $FromDate }) }
            if ($ToDate) { $Updates = $Updates.Where({ $_.LastUpdated -le $ToDate }) }
            if ($LastDays) {
                $CutoffDate = (Get-Date).AddDays(-$LastDays)
                $Updates = $Updates.Where({ $_.LastUpdated -ge $CutoffDate })
            }

            # Apply size filters
            if ($MinSize -or $MaxSize) {
                $Multiplier = if ($SizeUnit -eq "GB") { 1024 } else { 1 }
                $Updates = $Updates.Where({
                        $size = [double]($_.Size -replace ' MB$','')
                        $meetsMin = -not $MinSize -or $size -ge ($MinSize * $Multiplier)
                        $meetsMax = -not $MaxSize -or $size -le ($MaxSize * $Multiplier)
                        $meetsMin -and $meetsMax
                    })
            }
            #endregion Apply Filters

            #region Sorting and Output
            # Apply sorting
            $Updates = switch ($SortBy) {
                "Date" { $Updates | Sort-Object LastUpdated -Descending:$Descending }
                "Size" { $Updates | Sort-Object { [double]($_.Size -replace ' MB$','') } -Descending:$Descending }
                "Title" { $Updates | Sort-Object Title -Descending:$Descending }
                "Classification" { $Updates | Sort-Object Classification -Descending:$Descending }
                "Product" { $Updates | Sort-Object Products -Descending:$Descending }
                default { $Updates }
            }

            # Display result summary
            Write-CrateLog -Data "Search completed for: $searchQuery" -Level "Info"
            Write-CrateLog -Data "Found $($Updates.Count) updates" -Level "Info"

            if ($Updates.Count -ge $MaxResults) {
                Write-CrateLog -Data "Result limit of $MaxResults reached. Please refine your search criteria." -Level "Warning"
            }

            # Format and return results
            switch ($Format) {
                "Default" {
                    if ($Properties) { $Updates | Select-Object $Properties }
                    else { $Updates }
                }
                "CSV" {
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Csv -NoTypeInformation }
                    else { $Updates | ConvertTo-Csv -NoTypeInformation }
                }
                "JSON" {
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Json }
                    else { $Updates | ConvertTo-Json }
                }
                "XML" {
                    if ($Properties) { $Updates | Select-Object $Properties | ConvertTo-Xml -As String }
                    else { $Updates | ConvertTo-Xml -As String }
                }
            }
            #endregion Sorting and Output
        }
        catch {
            Write-CrateLog -Data "Error processing search request: $($_.Exception.Message)" -Level "Error"
            Complete-CrateOperation -Operation "Microsoft Catalog Update Search" -Success $false
        }
    }

    end {
        $ProgressPreference = "Continue"
        Complete-CrateOperation -Operation "Microsoft Catalog Update Search" -Success $true
    }
}