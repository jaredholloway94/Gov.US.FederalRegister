#region     < Abstact Argument Completer Bases

function StandardCompleter
{
    param
    (
        [String[]]
        $CompletionsList,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CompletionsList

    # filter $Completions by anything already typed.
    if ($WordToComplete)
    {
        $Completions = $Completions | where {$_ -like "*$WordToComplete*"}
    }

    # wrap $Completions with 'non-word' characters in single-quotes.
    $Completions = $Completions | foreach { if ($_ -match "^\w*$") {"$_"} else {"`'$_`'"} }
    
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}

function ArrayCompleter
{
    param
    (
        [String[]]
        $CompletionsList,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CompletionsList

    # filter $Completions by anything already typed.
    if ($WordToComplete)
    {
        Write-Host $WordToComplete
        $Completions = $Completions | where {$_ -like "*$WordToComplete*"}
    }

    # wrap $Completions with 'non-word' characters in single-quotes.
    $Completions = $Completions | foreach { if ($_ -match "^\w*$") {"$_"} else {"`'$_`'"} }
    
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}


function CommentedCompleterFromKeys
{
    # "Key <#  Value  #>" where KEY -like $WordToComplete

    param
    (
        [Hashtable]
        $CommentsDict,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CommentsDict.Keys

    # filter completions by anything already typed.
    if ($WordToComplete)
    {
        $WordToComplete = $WordToComplete.Split(',')[-1]
        $Completions = $Completions | where {$_ -like "*$WordToComplete*"}
    }

    # wrap completions with 'non-word' characters in single-quotes.
    # add comments to tab-completion, from dict vals.
    $Completions = $Completions | foreach {
        if ($_ -match "^\w*$") {"$_ <#  $($CommentsDict[$_])  #>"}
        else {"`'$_`' <#  $($CommentsDict[$_])  #>"}
    }
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}


function CommentedCompleterFromValues
{
    # "Key <#  Value  #>" where VALUE -like $WordToComplete

    param
    (
        [Hashtable]
        $CommentsDict,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CommentsDict.Keys

    # filter completions by anything already typed.
    if ($WordToComplete)
    {
        $WordToComplete = $WordToComplete.Split(',')[-1]
        $Completions = $Completions | where {$CommentsDict[$_] -like "*$WordToComplete*"}
    }

    # wrap completions with 'non-word' characters in single-quotes.
    # add comments to tab-completion, from dict vals.
    $Completions = $Completions | foreach {
        if ($_ -match "^\w*$") {"$_ <#  $($CommentsDict[$_])  #>"}
        else {"`'$_`' <#  $($CommentsDict[$_])  #>"}
    }
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}

#endregion Abstract Argument Completer Bases >


#region     < Api Helper Functions

function Build-QueryString
{
    <#
        .SYNOPSIS
        Turns an array of "parameter=value" strings into a correctly-formatted Url query string.

    #>

    [CmdletBinding()]

    param
    (
        # An ordered dictionary of parameter:value pairs
        # !!! Expects all parameter and value strings to be cleaned/formatted/url-encoded !!!
        [Parameter()]
        [String[]]
        $QueryParameters
    )

    $first,$rest = $QueryParameters
    
    $QueryString = ""
    if ($first) {$QueryString += "?$first"}
    if ($rest) {$rest | foreach {$QueryString += "&$_"}}

    return $QueryString
}

#endregion  Api Helper Functions >