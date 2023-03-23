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
        $line = ($commandAst.CommandElements[1..($commandAst.CommandElements.Count - 1)] -join " ") + $tail
    } else {
        $line = $tail
    }
    $opts = (runme --runme-compgen "$runmefile" "$line" 2>$null).Split("`n")
    $opts2 = @()
    foreach ($opt in $opts) {
        if ($opt -match '^-') {
            if ($commandAst.CommandElements[$commandAst.CommandElements.Count - 1] -match '^-') {
                $opts2 += $opt
            }
        } elseif ($opt -match '^`[^` ]+`$') {
            $choices = (runme $opt.Substring(1, $opt.Length - 2) 2>$null).Split("`n")
            $opts2 += $choices
        } elseif ($opt -match '^<') {
            if ($opt -imatch "file|path>(\.\.\.)?") {
                $comp_file = True
            } elseif ($opt -imatch "dir>(\.\.\.)?") {
                $comp_dir = True;
            } else {
                $opts2 += $opt
            }
        } else {
            $opts2 += $opt
        }
    }

    $result = ($opts2 | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { 
            if ($_.StartsWith("-")) {
                $t = [System.Management.Automation.CompletionResultType]::ParameterName
            } else {
                $t = [System.Management.Automation.CompletionResultType]::ParameterValue
            }
            [System.Management.Automation.CompletionResult]::new($_, $_, $t, '-')
        })

    $paths = @()
    if ($comp_file) {
        $paths = (Get-ChildItem -Path "$wordToComplete*" | Select-Object -ExpandProperty Name)
    } elseif ($comp_dir) {
        $paths = (Get-ChildItem -Attributes Directory -Path "$wordToComplete*" | Select-Object -ExpandProperty Name)
    }
    foreach ($path in $paths) {
        $t = [System.Management.Automation.CompletionResultType]::ParameterValue
        $result.Add([System.Management.Automation.CompletionResult]::new($path, $path, $t, '-'))
    }

    return $result
}

Register-ArgumentCompleter -Native -ScriptBlock $_runmeCompletion -CommandName runme