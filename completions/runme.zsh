# Zsh completion for runme

_runme_completion()
{
    local runmefile line opts opts2
    runmefile=$(runme --runme-file 2>/dev/null)
    line="${words[2,-1]}"
    if [[ $? -ne 0 ]]; then
        return 0
    fi
    IFS=$'\n'
    opts=( $(runme --runme-compgen "$runmefile" "$line" 2>/dev/null) )
    if [[ ${#opts[@]} == 0 ]]; then
        return 0
    elif [[ ${#opts[@]} == 1 ]]; then
        if [[ "${opts[1]}" == \`*\` ]]; then
            opts=( $(runme "${opts:1:-1}" 2>/dev/null) )
        fi
    fi
    
    opts2=()
    for item in "${opts[@]}"; do
        if [[ "$item" == "<FILE>" ]] || [[ "$item" == "<PATH>" ]] || [[ "$item" == "<FILE>..." ]] || [[ "$item" == "<PATH>..." ]]; then
            _path_files
        elif [[ "$item" == "<DIR>" ]] || [[ "$item" == "<DIR>..." ]]; then
            _path_files -/
        else
            opts2+=("$item")
        fi
    done

    if [[ ${#opts2[@]} -gt 0 ]]; then
        compadd -- $opts2[@]
    fi
}

compdef _runme_completion runme