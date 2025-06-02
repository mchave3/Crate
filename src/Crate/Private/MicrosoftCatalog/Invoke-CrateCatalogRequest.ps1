<#
.SYNOPSIS
    Invokes HTTP requests to the Microsoft Update Catalog

.DESCRIPTION
    This function handles HTTP requests to the Microsoft Update Catalog website.
    It includes error handling for common catalog errors and manages security protocols.

.NOTES
    Name:        Invoke-CrateCatalogRequest.ps1
    Author:      Mickaël CHAVE
    Created:     02/06/2025
    Version:     25.6.2.5
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

.LINK
    https://github.com/mchave3/Crate

.EXAMPLE
    Invoke-CrateCatalogRequest -Uri "https://www.catalog.update.microsoft.com/Search.aspx?q=Windows"
    Makes a GET request to the Microsoft Update Catalog search page
#>
function Invoke-CrateCatalogRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $Method = "Get"
    )

    try {
        Write-CrateLog -Data "Preparing to invoke catalog request to $Uri" -Level "Debug"
        Set-CrateTempSecurityProtocol

        $Headers = @{
            "Cache-Control" = "no-cache"
            "Pragma"        = "no-cache"
        }

        $Params = @{
            Uri = $Uri
            UseBasicParsing = $true
            ErrorAction = "Stop"
            Headers = $Headers
        }

        Write-CrateLog -Data "Sending web request to Microsoft Update Catalog" -Level "Debug"
        $Results = Invoke-WebRequest @Params
        $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
        $HtmlDoc.LoadHtml($Results.RawContent.ToString())
        $NoResults = $HtmlDoc.GetElementbyId("ctl00_catalogBody_noResultText")
        $ErrorText = $HtmlDoc.GetElementbyId("errorPageDisplayedError")

        if ($null -eq $NoResults -and $null -eq $ErrorText) {
            Write-CrateLog -Data "Successfully received catalog response" -Level "Debug"
            return [MSCatalogResponse]::new($HtmlDoc)
        } elseif ($ErrorText) {
            if ($ErrorText.InnerText -match '8DDD0010') {
                Write-CrateLog -Data "Microsoft Update Catalog error 8DDD0010 encountered" -Level "Error"
                throw "The catalog.microsoft.com site has encountered an error with code 8DDD0010. Please try again later."
            } else {
                Write-CrateLog -Data "Microsoft Update Catalog error: $($ErrorText.InnerText)" -Level "Error"
                throw "The catalog.microsoft.com site has encountered an error: $($ErrorText.InnerText)"
            }
        } else {
            Write-CrateLog -Data "No results found for $Uri" -Level "Warning"
        }
    } catch {
        Write-CrateLog -Data "Error during catalog request: $_" -Level "Error"
    } finally {
       Set-CrateTempSecurityProtocol -ResetToDefault
    }
}