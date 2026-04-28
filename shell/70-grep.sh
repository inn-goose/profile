# grep

alias grep='grep --color=auto'
export GREP_COLOR=32

_grepParams='-RHsn'
function G() { grep $_grepParams "$2" $1 | grep -v "\.git" | grep -v "Binary file" | grep "$2" ; }
