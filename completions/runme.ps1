# Powershell completion for runme

$_runmeCompletion = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $runmefile = $(runme --runme-file 2>$null)
    if (!$runmefile) {
        return;
    }
    if ($wordToComplete.ToString() -eq "") {
        $tail = " "
    } else {
        $tail = ""
    }
    if ($commandAst.CommandElements.Count -gt 1) {
        $cmds = ($commandAst.CommandElements[1..($commandAst.CommandElements.Count - 1)] -join " ") + $tail
    } else {
        $cmds = $tail
    }
    $comps = (runme --runme-compgen "$runmefile" "$cmds" 2>$null)
    if ($comps -match '^`[^` ]+`$') {
        $comps = (runme $comps.Substring(1, $comps.Length - 2) 2>$null)
    } elseif ($comps -eq "<FILE>" -or $comps -eq "<PATH>" -or $comps -eq "<FILE>..." -or $comps -eq "<PATH>...") {
        $comps = ("")
    } elseif ($comps -eq "<DIR>" -or $comps -eq "<DIR>...") {
        $comps = ("")
    }
    $comps -split "`n" | 
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