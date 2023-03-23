# Zsh completion for runme

_runme_completion()
{
    local scriptfile=$(runme --runme-file 2>/dev/null)
    if [[ ! -f "$scriptfile" ]]; then
        return 0
    fi
    local line="${words[2,-1]}"
    local IFS=$'\n'
    local compgen_values=( $(runme --runme-compgen "$scriptfile" "$line" 2>/dev/null) )
    local candicates=()
    local option_values=()
    local value_kind=0
    for item in ${compgen_values[@]}; do
        if [[ "$item" == '-'* ]]; then
            option_values+=( "$item" )
        elif [[ "$item" == \`*\` ]]; then
            local choices=( $(runme "${item:1:-1}" 2>/dev/null) )
            candicates=( "${candicates[@]}" "${choices[@]}" )
        elif [[ "$item" == '<'* ]]; then
            if echo "$item" | grep -qi '<args>...'; then
                value_kind=1
            elif echo "$item" | grep -qi '\(file\|path\)>\(\.\.\.\)\?'; then
                value_kind=2
            elif echo "$item" | grep -qi 'dir>\(\.\.\.\)\?'; then
                value_kind=3
            else
                value_kind=9
            fi
        else
            candicates+=( "$item" )
        fi
    done
    if [[ "$value_kind" == 0 ]]; then
        if [[ "${#candicates[@]}" -eq 0 ]]; then
            candicates=( "${option_values[@]}" )
        fi
    elif [[ "$value_kind" == 1 ]]; then
        if [[ "${#candicates[@]}" -eq 0 ]]; then
            candicates=( "${option_values[@]}" )
        fi
        if [[ "${#candicates[@]}" -eq 0 ]]; then
            _path_files
        fi
    elif [[ "$value_kind" == 2 ]]; then
        _path_files
    elif [[ "$value_kind" == 3 ]]; then
        _path_files -/
    fi
    if [[ ${#candicates[@]} -gt 0 ]]; then
        compadd -- $candicates[@]
    fi
}

compdef _runme_completion runme