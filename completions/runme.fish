# Fish completion for scripts written with argc
#
# All argc scripts share the same completion function.
# To add completion to a argc script, simply add the script name to $ARGC_SCRIPTS.

function __fish_complete_runme
    set -l tokens (commandline -c | string trim -l | string split " " --)
    set -l runmefile (runme --runme-file 2>/dev/null)
    if test -z $runmefile
        return 0
    end
    set -l IFS '\n'
    set -l opts (runme --runme-compgen "$runmefile" "$tokens[2..]" 2>/dev/null)
    set comp_file 0
    set comp_dir 0
    for item in $opts
        if string match -qr '^`[^` ]+`' -- "$item"
            set -l name (string sub "$item" -s 2 -e -1)
            runme $name 2>/dev/null
        else if test "$item" = "<FILE>" || test "$item" = "<PATH>" || test "$item" = "<FILE>..." || test "$item" = "<PATH>..."
            set comp_file 1
        else if test "$item" = "<DIR>" || test "$item" = "<DIR>..."
            set comp_dir 1
        else
            echo $item
        end
    end
    if [ $comp_file -eq 1 ]
        __fish_complete_path
    else if [ $comp_dir -eq 1 ]
        __fish_complete_directories 
    end
end

complete -x -c runme  -n 'true' -a "(__fish_complete_runme)"