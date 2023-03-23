# Zsh completion for runme

_runme_completion()
{
    local argcfile line opts opts2 comp_file comp_dir
    runmefile=$(runme --runme-file 2>/dev/null)
    line="${words[2,-1]}"
    if [[ ! -f "$runmefile" ]]; then
        return 0
    fi
    line="${words[2,-1]}"
    IFS=$'\n'
    opts=( $(runme --runme-compgen "$runmefile" "$line" 2>/dev/null) )
    opts2=()
    for opt in ${opts[@]}; do
        if [[ "$opt" == '-'* ]]; then
            if [[ "$words[-1]" == '-'* ]]; then
                opts2+=( "$opt" )
            fi
        elif [[ "$opt" == \`*\` ]]; then
            local choices=( $(runme "${opt:1:-1}" 2>/dev/null) )
            opts2=( "${opts2[@]}" "${choices[@]}" )
        elif [[ "$opt" == '<'* ]]; then
            if echo "$opt" | grep -qi '\(file\|path\)>\(\.\.\.\)\?'; then
                comp_file=1
            elif echo "$opt" | grep -qi 'dir>\(\.\.\.\)\?'; then
                comp_dir=1
            else
                opts2+=( "$opt" )
            fi
        else
            opts2+=( "$opt" )
        fi
    done
    if [[ "$comp_file" == 1 ]]; then
        _path_files
    elif [[ "$comp_dir" == 1 ]]; then
        _path_files -/
    fi

    if [[ ${#opts2[@]} -gt 0 ]]; then
        compadd -- $opts2[@]
    fi
}

compdef _runme_completion runme