#region     < Imports

# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Enums.ps1")
# . (Join-Path $PSScriptRoot "Gov.US.FederalRegister.Utils.ps1")

#endregion  Imports >


#region     < Argument Completers

function DocumentFieldCompleter
{
    param
    (
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
    
    $completer_args = @{
        CompletionsList = $DocumentFieldEnum
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    ArrayCompleter @completer_args
}


function AgencyCompleterCompleter
{
    param
    (
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
    
    $completer_args = @{
        CompletionsList = $AgencyEnum
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    ArrayCompleter @completer_args
}


function CfrTopicCompleter
{
    param
    (
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
    
    $completer_args = @{
        CompletionsList = $CfrTopicEnum
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    ArrayCompleter @completer_args
}

#endregion  Argument Completers >