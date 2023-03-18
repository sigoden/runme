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
    $opts = (runme --runme-compgen "$runmefile" "$cmds" 2>$null).Split("`n")
    $opts2 = @()
    foreach ($opt in $opts) {
        if ($opt -match '^`[^` ]+`$') {
            $choices = (runme $opt.Substring(1, $opt.Length - 2) 2>$null).Split("`n")
            $opts2 += $choices
        } elseif ($opt -eq "<FILE>" -or $opt -eq "<PATH>" -or $opt -eq "<FILE>..." -or $opt -eq "<PATH>...") {
        } elseif ($opt -eq "<DIR>" -or $opt -eq "<DIR>...") {
        } else {
            $opts2 += $opt
        }
    }

    $opts2 | 
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