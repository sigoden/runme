# Bash completion for runme

_runme_completion() {
    local runmefile cur opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    runmefile=$(runme --runme-file 2>/dev/null)
    if [ $? != 0 ]; then
        return 0
    fi
    opts=$(runme --runme-compgen "$runmefile" ${COMP_WORDS[@]:1:$((${#COMP_WORDS[@]} - 2))} 2>/dev/null)
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
}

complete -F _runme_completion -o bashdefault -o default runme
