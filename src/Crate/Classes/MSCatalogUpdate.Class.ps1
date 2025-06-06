class MSCatalogUpdate {
    [string] $Title
    [string] $Products
    [string] $Classification
    [datetime] $LastUpdated
    [string] $Version
    [string] $Size
    [string] $SizeInBytes
    [string] $Guid
    [string[]] $FileNames

    MSCatalogUpdate() {}

    MSCatalogUpdate($Row, $IncludeFileNames) {
        $Cells = $Row.SelectNodes("td")
        $this.Title = $Cells[1].innerText.Trim()
        $this.Products = $Cells[2].innerText.Trim()
        $this.Classification = $Cells[3].innerText.Trim()
        $this.LastUpdated = (ConvertFrom-CrateDateString -DateString $Cells[4].innerText.Trim())
        $this.Version = $Cells[5].innerText.Trim()
        $this.Size = $Cells[6].SelectNodes("span")[0].InnerText
        $this.SizeInBytes = [Int64] $Cells[6].SelectNodes("span")[1].InnerText
        $this.Guid = $Cells[7].SelectNodes("input")[0].Id
        $this.FileNames = if ($IncludeFileNames) {
            $Links = Get-CrateUpdateLink -Guid $Cells[7].SelectNodes("input")[0].Id
            foreach ($Link in $Links.Matches) {
                $Link.Value.Split('/')[-1]
            }
        }
    }
}