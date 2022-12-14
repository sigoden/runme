# Zsh completion for runme

_runme_completion()
{
    local runmefile values
    runmefile=$(runme --runme-file 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return 0
    fi
    values=( $(runme --runme-compgen "$runmefile" $words[2,-2] 2>/dev/null) )
    compadd -- $values[@]
    return 0
}

compdef _runme_completion runme