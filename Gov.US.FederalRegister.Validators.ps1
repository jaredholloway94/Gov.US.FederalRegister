#region     < Imports

# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Enums.ps1")

#endregion  Imports >

#region     < Argument Validators

function DocumentFieldValidator
{
    <#
        .SYNOPSIS
        - can be empty (default fields will be retrieved)
        - can be single field name
        - can be multiple field names separated by commas
    #>

    if ($_ -eq "")
    { # default document fields
        $true
    }
    elseif ($_ -eq "all")
    { # all document fields
        $true
    }
    elseif ($_ -like "*,*")
    { # multiple document fields
        foreach ($i in $_.Split(",")) {$i -in $DocumentFieldEnum}
    }
    else
    { # one document field
        $_ -in $DocumentFieldEnum
    }
}


function AgencyValidator
{
    <#
        .SYNOPSIS
        - can be empty (default fields will be retrieved)
        - can be single field name
        - can be multiple field names separated by commas
    #>

    if ($_ -eq "")
    { # default document fields
        $true
    }
    elseif ($_ -eq "all")
    { # all document fields
        $true
    }
    elseif ($_ -like "*,*")
    { # multiple document fields
        foreach ($i in $_.Split(",")) {$i -in $AgencyEnum}
    }
    else
    { # one document field
        $_ -in $AgencyEnum
    }
}


function CfrTopicValidator
{
    <#
        .SYNOPSIS
        - can be empty (default fields will be retrieved)
        - can be single field name
        - can be multiple field names separated by commas
    #>

    if ($_ -eq "")
    { # default document fields
        $true
    }
    elseif ($_ -eq "all")
    { # all document fields
        $true
    }
    elseif ($_ -like "*,*")
    { # multiple document fields
        foreach ($i in $_.Split(",")) {$i -in $CfrTopicEnum}
    }
    else
    { # one document field
        $_ -in $CfrTopicEnum
    }
}

#endregion  Argument Validators >