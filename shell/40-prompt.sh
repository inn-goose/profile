# shell

stty stop ''

# Colors
PS_CYAN="\[\033[0;36m\]"
PS_PINK="\[\033[0;95m\]"
PS_RESET="\[\033[0m\]"

# Role bindings — change these to re-theme without touching the prompt strings
PS_CONSOLE_COLOR=${PS_CYAN}
# PS_CONSOLE_COLOR=${PS_PINK}

if [[ -z "${TMUX_PANE}" ]]; then
    PS_PREFIX=
else
    PS_PREFIX="${PS_CONSOLE_COLOR}${TMUX_PANE}${PS_RESET} "
fi
#echo "${PS_PREFIX}";

PS_CURRENT_TIME="${PS_CONSOLE_COLOR}[\T]${PS_RESET}"
PS_HOST_NAME="${PS_CONSOLE_COLOR}\h${PS_RESET}"
PS_USER_NAME="\[\033[0;32m\]\u${PS_RESET}"
PS_ROOT_NAME="\[\033[1;31m\]\u${PS_RESET}"
PS_TERM_SIGN="${PS_CONSOLE_COLOR}\$${PS_RESET}"

PS_CURRENT_FOLDER="\W"

if [[ ${EUID} -ne 0 && $(whoami) != "root" ]]; then
    #export PS1="${PS_HOST_NAME}@${PS_USER_NAME}:${PS_CURRENT_FOLDER}${PS_TERM_SIGN} "
    #export PS1="${PS_HOST_NAME}:${PS_CURRENT_FOLDER}${PS_TERM_SIGN} "
    export PS1="${PS_PREFIX}${PS_CURRENT_TIME} ${PS_HOST_NAME}:${PS_CURRENT_FOLDER}${PS_TERM_SIGN} "
else
    export PS1="${PS_HOST_NAME}@${PS_ROOT_NAME}:${PS_CURRENT_FOLDER}${PS_TERM_SIGN} "
fi
