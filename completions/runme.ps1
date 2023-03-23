# Powershell completion for runme

$_runmeCompletion = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $scriptfile = $(runme --runme-file 2>$null)
    if (!$scriptfile) {
        $scriptfile = $commandAst.CommandElements[0]
        if (-not(Test-Path -Path $scriptfile -PathType Leaf)) {
            return;
        }
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
    $compgen_values = (runme --runme-compgen "$scriptfile" "$line" 2>$null).Split("`n")
    $candicates = @()
    $option_values = @()
    $value_kind = 0
    foreach ($item in $compgen_values) {
        if ($item -match '^-') {
            $option_values += $item
        } elseif ($item -match '^`[^` ]+`$') {
            $choices = (runme $item.Substring(1, $item.Length - 2) 2>$null).Split("`n")
            $candicates += $choices
        } elseif ($item -match '^<') {
            if ($item -imatch "<args>...") {
                $value_kind = 1
            } elseif ($item -imatch "file|path>(\.\.\.)?") {
                $value_kind = 2
            } elseif ($item -imatch "dir>(\.\.\.)?") {
                $value_kind = 3
            } else {
                $value_kind = 9
            }
        } else {
            $candicates += $item
        }
    }
    $paths = @()
    if ($value_kind -eq 0) {
        if ($candicates.Count -eq 0) {
            $candicates = $option_values
        }
    } elseif ($value_kind -eq 1) {
        if ($candicates.Count -eq 0) {
            $candicates = $option_values
        }
        if ($candicates.Count -eq 0) {
            $paths = (Get-ChildItem -Path "$wordToComplete*" | Select-Object -ExpandProperty Name)
        }
    } elseif ($value_kind -eq 2) {
        $paths = (Get-ChildItem -Path "$wordToComplete*" | Select-Object -ExpandProperty Name)
    } elseif ($value_kind -eq 3) {
        $paths = (Get-ChildItem -Attributes Directory -Path "$wordToComplete*" | Select-Object -ExpandProperty Name)
    }

    $param_value = [System.Management.Automation.CompletionResultType]::ParameterValue
    $param_name = [System.Management.Automation.CompletionResultType]::ParameterName
    $result = ($candicates | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { 
            if ($_.StartsWith("-")) {
                $t = $param_name
            } else {
                $t = $param_value
            }
            [System.Management.Automation.CompletionResult]::new($_, $_, $t, '-')
        })

    foreach ($path in $paths) {
        $result.Add([System.Management.Automation.CompletionResult]::new($path, $path, $param_value, '-'))
    }

    return $result
}

Register-ArgumentCompleter -Native -ScriptBlock $_runmeCompletion -CommandName runme