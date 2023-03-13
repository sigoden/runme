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
    if [[ "$opts" = __argc_compgen_cmd:* ]]; then
        COMPREPLY=( $(compgen -W "$(runme ${opts#__argc_compgen_cmd:} 2>/dev/null)" -- "${cur}") )
    else
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    fi
    return 0
}

complete -F _runme_completion -o bashdefault -o default runme
