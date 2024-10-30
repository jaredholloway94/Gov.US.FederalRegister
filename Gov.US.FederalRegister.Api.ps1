#region     < Imports

# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Enums.ps1")
# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Utils.ps1")
# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Completers.ps1")
# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Validators.ps1")

#endregion  Imports >


#region     < Global Variables

# history of each API request sent, response received, and name of the function that made the request; for debugging purposes
$Global:RequestResponseHistory = [System.Collections.ArrayList]@()

$ApiUri = "https://www.federalregister.gov/api/v1"

#endregion  Global Variables >


#region     < API Methods

function Get-FederalRegisterDocument
{
    <#
        .SYNOPSIS
        Fetch a single Federal Register document.

        .LINK
        https://www.federalregister.gov/developers/documentation/api/v1#/Federal%20Register%20Documents/get_documents__document_number___format_

    #>

    [CmdletBinding()]

    param
    (
        # Federal Register document number
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $DocumentNumber,

        # Which attributes of the document to return:
        #   - Leave blank for default attribute set
        #   - Type 'all' to return all available attributes
        #   - [Tab] to cycle thru available attributes
        #   - Separate multiple attributes with commas
        [Parameter()]
        [String[]]
        [ArgumentCompleter({ DocumentFieldCompleter @args })]
        [ValidateScript({ DocumentFieldValidator })]
        $Fields,
        
            # What format the response should be in:
        #   - json
        #   - csv
        [Parameter()]
        [String]
        [ValidateSet("json","csv")]
        $Format = "json"
    )

    $EndpointUri = "/documents/$DocumentNumber.$Format"

    $QueryParameters = @()

    if ($Fields)
    {
        if ($Fields -eq "all") {$Fields = $DocumentFieldEnum}
        $Fields | foreach { $QueryParameters += "fields[]=$_" }
    }

    $QueryString = Build-QueryString $QueryParameters

    $request = @{
        Uri = $ApiUri + $EndpointUri + $QueryString
        Method = "GET"
        Headers = @{
            accept = "*/*"
        }
        Body = {
                
        }
    }

    $response = Invoke-WebRequest @request

    $null = $Global:RequestResponseHistory.Add(
        @{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        }
    )

    $Document = $response.Content | ConvertFrom-Json

    return $Document
}


function Get-FederalRegisterDocuments
{
    <#
        .SYNOPSIS
        Fetch multiple Federal Register documents.

        .LINK
        https://www.federalregister.gov/developers/documentation/api/v1#/Federal%20Register%20Documents/get_documents__document_numbers___format_

    #>

    [CmdletBinding()]

    param
    (
        # Federal Register document numbers
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]
        $DocumentNumbers,

        # Which attributes of the document to return:
        #   - Leave blank for default attribute set
        #   - Type 'all' to return all available attributes
        #   - [Tab] to cycle thru available attributes
        #   - Separate multiple attributes with commas
        [Parameter()]
        [String[]]
        [ArgumentCompleter({ DocumentFieldCompleter @args })]
        [ValidateScript({ DocumentFieldValidator })]
        $Fields,
        
            # What format the response should be in:
        #   - json
        #   - csv
        [Parameter()]
        [String]
        [ValidateSet("json","csv")]
        $Format = "json"
    )

    $EndpointUri = "/documents/$($DocumentNumbers -join ",").$Format"

    $QueryParameters = @()

    if ($Fields)
    {
        if ($Fields -eq "all") {$Fields = $DocumentFieldEnum}
        $Fields | foreach { $QueryParameters += "fields[]=$_" }
    }

    $QueryString = Build-QueryString $QueryParameters

    $request = @{
        Uri = $ApiUri + $EndpointUri + $QueryString
        Method = "GET"
        Headers = @{
            accept = "*/*"
        }
        Body = @{

        }
    }

    $response = Invoke-WebRequest @request

    $null = $Global:RequestResponseHistory.Add(
        @{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        }
    )

    $results = $response.Content | ConvertFrom-Json

    if ($results.count -gt 1) {return $results.results}
    else {return @($results)}
}


function Search-FederalRegisterDocuments
{
    <#
        .SYNOPSIS
        Search all Federal Register documents published since 1994.
        
        .LINK
        https://www.federalregister.gov/developers/documentation/api/v1#/Federal%20Register%20Documents/get_documents__format_
        
    #>
    
    [CmdletBinding()]
    
    param
    (
        # Full text search.
        [Parameter(ValueFromPipeline)]
        [String]
        $SearchTerm,

        # How many documents to return at once. (1000 max)
        [Parameter()]
        [Int]
        $ResultsPerPage=100,

        # The page number of the result set.
        [Parameter()]
        [Int]
        $ResultsPageNumber,

        # The order the results should be returned in.
        [Parameter()]
        [String]
        [ValidateSet("relevance","newest","oldest","executive_order_number")]
        $SortOrder,

        # Find documents published on a given date. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $PubDate_Exact,

        # Find documents published in a given year. (YYYY)
        [Parameter()]
        [String]
        $PubDate_Year,

        # Find documents published on or after a given date. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $PubDate_GTE,

        # Find documents published on or before a given day. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $PubDate_LTE,

        # Find documents that went into effect on a given day. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $EffDate_Exact,

        # Find documents that went into effect in a given day. (YYYY)
        [Parameter()]
        [String]
        $EffDate_Year,

        # Find documents that went into effect on or after a given day. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $EffDate_GTE,

        # Find documents that went into effect on or before a given day. (YYYY-MM-DD)
        [Parameter()]
        [String]
        $EffDate_LTE,

        # Find documents published by a given agency or agencies.
        [Parameter()]
        [String[]]
        [ArgumentCompleter({ AgencyCompleter @args })]
        [ValidateScript({ AgencyValidator })]
        $Agencies,

        # Find documents of a given type. (Rule, Proposed Rule, Notice, or Presidential Document)
        [Parameter()]
        [String[]]
        [ValidateSet("final_rule","proposed_rule","notice","presidential")]
        $DocTypes,
        
        # Find documents of a given Presidential Document type. (Only valid for Presidential Documents)
        [Parameter()]
        [String[]]
        [ValidateSet("determination","executive_order","memorandum","notice","proclamation","presidential_order","other")]
        $PresDocTypes,

        # Find documents signed by a given President. (Only valid for Presidential Documents)
        [Parameter()]
        [String[]]
        [ValidateSet("william_j_clinton","george_w_bush","barrack_obama","donald_trump","joe_biden")]
        $SigningPresidents,

        # Agency docket number associated with the document.
        [Parameter()]
        [String]
        $DocketId,

        # Regulation ID Number (RIN) associated with document.
        [Parameter()]
        [String]
        $RegulationId,

        # Limit to documents that appeared within a particular section of FederalRegister.gov.
        [Parameter()]
        [String[]]
        [ValidateSet("business_and_industry","environment","health_and_public_welfare","money","science_and_technology","world")]
        $FedRegSections,

        # Limit to documents associated with a particular topic. (CFR Indexing term)
        [Parameter()]
        [String[]]
        [ArgumentCompleter({ CfrTopicCompleter @args })]
        [ValidateScript({ CfrTopicValidator })]
        $Topics,
        
        # Deemed Significant Under EO 12866. (1 for True; 0 for False)
        [Parameter()]
        [Int]
        [ValidateSet(1,0)]
        $Significant,

        # Documents affecting the associated CFR Title(s).
        [Parameter()]
        [Int]
        $CfrTitleNumber,

        # Documents affecting the associated CFR Part(s). (Requires CfrTitleNumber to be provided)
        [Parameter()]
        [Int]
        $CfrPartNumber,

        # Enter zipcode or city and state.
        [Parameter()]
        [String]
        $NearLocation,

        # Maximum distance from location in miles. (max 200)
        [Parameter()]
        [String]
        $DistanceFromLocation,

        # Which attributes of the document to return:
        #   - Leave blank for default attribute set
        #   - Type 'all' to return all available attributes
        #   - [Tab] to cycle thru available attributes
        #   - Separate multiple attributes with commas
        [Parameter()]
        [String[]]
        [ArgumentCompleter({ DocumentFieldCompleter @args })]
        [ValidateScript({ DocumentFieldValidator })]
        $Fields,
        
            # What format the response should be in:
        #   - json
        #   - csv
        [Parameter()]
        [String]
        [ValidateSet("json","csv")]
        $Format = "json"
    )

    $EndpointUri = "/documents.$Format"

    $QueryParameters = @()

    if ($Fields -eq "all")      { $Fields = $DocumentFieldEnum }
    if ($Fields)                { $Fields | foreach { $QueryParameters += "fields[]=$_" } }
    if ($ResultsPerPage)        { $QueryParameters += "per_page=$ResultsPerPage" }
    if ($ResultsPageNumber)     { $QueryParameters += "page=$ResultsPageNumber" }
    if ($SortOrder)             { $QueryParameters += "order=$SortOrder" }
    if ($SearchTerm)            { $QueryParameters += "conditions[term]=$([Uri]::EscapeUriString($SearchTerm))" }
    if ($PubDate_Exact)         { $QueryParameters += "conditions[publication_date][is]=$PubDate_Exact" }
    if ($PubDate_Year)          { $QueryParameters += "conditions[publication_date][year]=$PubDate_Year" }
    if ($PubDate_GTE)           { $QueryParameters += "conditions[publication_date][gte]=$PubDate_GTE" }
    if ($PubDate_LTE)           { $QueryParameters += "conditions[publication_date][lte]=$PubDate_LTE" }
    if ($EffDate_Exact)         { $QueryParameters += "conditions[effective_date][is]=$EffDate_Exact" }
    if ($EffDate_Year)          { $QueryParameters += "conditions[effective_date][year]=$EffDate_Year" }
    if ($EffDate_GTE)           { $QueryParameters += "conditions[effective_date][gte]=$EffDate_GTE" }
    if ($EffDate_LTE)           { $QueryParameters += "conditions[effective_date][lte]=$EffDate_LTE" }
    if ($Agencies)              { $Agencies | foreach { $QueryParameters += "conditions[agencies][]=$($_.Replace('_','-'))" } }
    if ($DocTypes)              { $DocTypes | foreach { switch ($_) {
                                                            "final_rule"    { $QueryParameters += "conditions[type][]=RULE" }
                                                            "proposed_rule" { $QueryParameters += "conditions[type][]=PRORULE" }
                                                            "notice"        { $QueryParameters += "conditions[type][]=NOTICE" }
                                                            "presidential"  { $QueryParameters += "conditions[type][]=PRESDOCU" }
                                                        } } }
    if ($PresDocTypes)          { $PresDocTypes | foreach { $QueryParameters += "conditions[presidential_document_type][]=$_" } }
    if ($SigningPresidents)     { $SigningPresidents | foreach { $QueryParameters += "conditions[][]=$($_.Replace('_','-'))" } }
    if ($DocketId)              { $QueryParameters += "conditions[docket_id]=$DocketId" }
    if ($RegulationId)          { $QueryParameters += "conditions[regulation_id_number]=$RegulationId" }
    if ($FedRegSections)        { $FedRegSections | foreach { $QueryParameters += "conditions[sections][]=$($_.Replace('_','-'))" } }
    if ($Topics)                { $Topics | foreach { $QueryParameters += "conditions[topics][]=$($_.Replace('_','-'))" } }
    if ($Significant)           { $QueryParameters += "conditions[significant]=$Significant" }
    if ($CfrTitleNumber)        { $QueryParameters += "conditions[cfr][title]=$CfrTitleNumber" }
    if ($CfrPartNumber)         { $QueryParameters += "conditions[cfr][part]=$CfrPartNumber" }
    if ($NearLocation)          { $QueryParameters += "conditions[near][location]=$NearLocation" }
    if ($DistanceFromLocation)  { $QueryParameters += "conditions[near][within]=$DistanceFromLocation" }

    $QueryString = Build-QueryString $QueryParameters
    
    $request = @{
        Uri = $ApiUri + $EndpointUri + $QueryString
        Method = "GET"
        Headers = @{
            accept = "*/*"
        }
        Body = @{
            
        }
    }

    $response = Invoke-RestMethod @request
    
    $null = $Global:RequestResponseHistory.Add(
        @{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        }
    )

    $results = $response.results

    return $results
}

#endregion  API Methods >


#region     < Testing



#endregion  Testing >
