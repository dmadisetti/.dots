function _complete
    set saved_pwd $PWD
    builtin cd $argv
    and PWD=$argv complete -C"cd $arg"
    builtin cd $saved_pwd
end
