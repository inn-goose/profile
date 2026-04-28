if [ -n "$PS1" ]; then

    PROFILE_DIR=~/.local/.profile

    for f in "$PROFILE_DIR"/shell/[0-9]*.sh; do
        source "$f"
    done

    case "$platform" in
        linux)    source "$PROFILE_DIR/shell/linux.sh" ;;
        darwin)   source "$PROFILE_DIR/shell/darwin.sh" ;;
        freebsd)  alias ls='ls -G -F -h'
                  export LSCOLORS="GxdxcxdxCxegedabagacad" ;;
    esac
    alias l='ls -l'
    alias ll='ls -la'

fi
