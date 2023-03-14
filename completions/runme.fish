# Fish completion for scripts written with argc
#
# All argc scripts share the same completion function.
# To add completion to a argc script, simply add the script name to $ARGC_SCRIPTS.

function __fish_complete_runme
    set -l line (commandline -opc) (commandline -ct)
    set -l tokens (echo $line | string trim | string split " " --)
    set -l runmefile (runme --runme-file 2>/dev/null)
    if test -z $runmefile
        return 0
    end
    set -l opts (runme --runme-compgen "$runmefile" $tokens[2..-1] 2>/dev/null)
    if string match -q "__argc_compgen_cmd:*" -- $opts
        set -l fn_name (string replace "__argc_compgen_cmd:" "" $opts)
        set opts (runme $fn_name 2>/dev/null)
    end
    echo $opts | string trim | string split " " --
end

complete -x -c runme  -n 'true' -a "(__fish_complete_runme)"