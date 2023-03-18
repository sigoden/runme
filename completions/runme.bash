# Bash completion for runme

_runme_completion() {
    local argcfile cur opts opts2 line index IFS comp_file comp_dir
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    runmefile=$(runme --runme-file 2>/dev/null)
    if [[ $? != 0 ]]; then
        return 0
    fi
    line=${COMP_LINE:${#COMP_WORDS[0]}}
    IFS=$'\n'
    opts=($(runme --runme-compgen "$runmefile" "$line" 2>/dev/null))
    opts2=()
    for opt in ${opts[@]}; do
        if [[ "$opt" == \`*\` ]]; then
            local choices=($(runme "${opt:1:-1}" 2>/dev/null))
            opts2=( "${opts2[@]}" "${choices[@]}" )
        elif [[ "$opt" == "<FILE>" ]] || [[ "$opt" == "<PATH>" ]] || [[ "$opt" == "<FILE>..." ]] || [[ "$opt" == "<PATH>..." ]]; then
            comp_file=1
        elif [[ "$opt" == "<DIR>" ]] || [[ "$opt" == "<DIR>..." ]]; then
            comp_dir=1
        else
            opts2+=( "$opt" )
        fi
    done
    if [[ "$comp_file" == 1 ]]; then
        compopt +o filenames 
    elif [[ "$comp_dir" == 1 ]]; then
        compopt +o dirnames
    fi
    if [[ ${#opts2[@]} -gt 0 ]]; then
        CANDIDATES=($(compgen -W "${opts2[*]}" -- "${cur}"))
        if [ ${#CANDIDATES[*]} -gt 0 ]; then
            COMPREPLY=($(printf '%q\n' "${CANDIDATES[@]}"))
        fi
    fi
}

complete -F _runme_completion -o bashdefault -o default runme
