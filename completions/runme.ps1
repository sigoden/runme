# Powershell completion for runme

$_runmeCompletion = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $runmefile = $(runme --runme-file 2>$null)
    if (!$runmefile) {
        return;
    }
    if ($wordToComplete) {
        $cmds = $commandAst.CommandElements[1..($commandAst.CommandElements.Count - 2)]
    } else {
        $cmds = $commandAst.CommandElements[1..($commandAst.CommandElements.Count - 1)]
    }
    (runme --runme-compgen "$runmefile" $cmds 2>$null) -split " " | 
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