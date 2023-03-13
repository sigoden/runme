# Powershell completion for runme

$_runmeCompletion = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $runmefile = $(runme --runme-file 2>$null)
    if (!$runmefile) {
        return;
    }
    if ($wordToComplete) {
        $words = $commandAst.CommandElements[1..($commandAst.CommandElements.Count - 2)]
    } else {
        $words = $commandAst.CommandElements[1..($commandAst.CommandElements.Count - 1)]
    }
    $comps = (runme --runme-compgen "$runmefile" $words 2>$null)
    $__argc_compgen_cmd="__argc_compgen_cmd:"
    if ($comps.StartsWith($__argc_compgen_cmd)) {
        $comps = $comps.Substring($__argc_compgen_cmd.Length)
        $comps = (runme $comps 2>$null)
        $comps = $comps.Trim()
    }
    $comps -split " " | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { 
            if ($_.StartsWith("-")) {
                $t = [System.Management.Automation.CompletionResultType]::ParameterName
            } else {
                $t = [System.Management.Automation.CompletionResultType]::ParameterValue
            }
            [System.Management.Automation.CompletionResult]::new($_, $_, $t, '-')
        }
}

Register-ArgumentCompleter -Native -ScriptBlock $_runmeCompletion -CommandName runme