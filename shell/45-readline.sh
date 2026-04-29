# readline / paste

# Disable bracketed-paste markers from the terminal.
# bash 3.2 (Apple default) doesn't strip \e[200~/\e[201~, so we tell the
# terminal not to send them. Remove this once on bash 4.4+ with proper
# `bind 'set enable-bracketed-paste on'`.
printf '\e[?2004l'
