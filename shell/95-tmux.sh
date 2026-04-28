# tmux

#alias fix_ssh_agent="source ~/.local/bin/_fix_ssh_agent"

#if [[ -z "${TMUX_PANE}" ]]; then
#    echo
#else
#    fix_ssh_agent
#fi

#export __CD_HOME_PATH="${HOME}"  # override on srceen creation
#function go() {
#    cd ${__CD_HOME_PATH}
#    echo ${PWD}
#}

#echo "go path: ${__CD_HOME_PATH}"

#function __tmux() {
#    __NAME=$1
#    __HOME_PATH=$2
#    if [ -z ${__NAME} ]; then
#        __NAME="default"
#    fi
#    if [ -z ${__HOME_PATH} ]; then
#        __HOME_PATH="${HOME}"
#    fi
#    echo "tmux name: ${__NAME}"
#    echo "go path: ${__HOME_PATH}"

#    export __TMUX_NAME=${__NAME}
#    unset __NAME

#    unset __CD_HOME_PATH
#    export __CD_HOME_PATH="${__HOME_PATH}"
#    unset __HOME_PATH

#    cd

#    ~/.local/bin/grab_ssh_agent

#    tmux -2u attach || tmux -2u new
#}
