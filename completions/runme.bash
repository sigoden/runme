# Bash completion for runme

_runme_completion() {
    local runmefile cur opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    runmefile=$(runme --runme-file 2>/dev/null)
    if [[ $? != 0 ]]; then
        return 0
    fi
    line=${COMP_LINE:${#COMP_WORDS[0]}}
    IFS=$'\n'
    opts=($(runme --runme-compgen "$runmefile" "$line" 2>/dev/null))
    if [[ ${#opts[@]} == 0 ]]; then
        return 0
    elif [[ ${#opts[@]} == 1 ]]; then
        if [[ "$opts" == \`*\` ]]; then
            opts=($(runme "${opts:1:-1}" 2>/dev/null))
        elif [[ "$opts" == "<FILE>" ]] || [[ "$opts" == "<PATH>" ]] || [[ "$opts" == "<FILE>..." ]] || [[ "$opts" == "<PATH>..." ]]; then
            opts=()
            compopt +o filenames 
        elif [[ "$opts" == "<DIR>" ]] || [[ "$opts" == "<DIR>..." ]]; then
            opts=()
            compopt +o dirnames
        fi
    fi
    if [[ ${#opts[@]} -gt 0 ]]; then
        CANDIDATES=($(compgen -W "${opts[*]}" -- "${cur}"))
        if [ ${#CANDIDATES[*]} -gt 0 ]; then
            COMPREPLY=($(printf '%q\n' "${CANDIDATES[@]}"))
        fi
    fi
}

complete -F _runme_completion -o bashdefault -o default runme
