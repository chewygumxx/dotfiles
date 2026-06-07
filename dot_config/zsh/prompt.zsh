# vim: noexpandtab:tabstop=4:shiftwidth=4:textwidth=80
# vim: foldlevel=2:foldmethod=expr

#
#
# ~/.config/zsh/prompt.zsh
#
#

autoload -U colors && colors
TIME="%F{#626262}[%f%F{#5f95fa}%D{%H}%f%F{#7171d3}:%f%F{#5f95fa}%D{%M}%f%F{#7171d3}:%f%F{#5f95fa}%D{%S}%f%F{#626262}]%f"

WORK_DIR="%F{#a75ed0}%~%f"

EXIT_CODE="%(?..%F{red}%B %?%b%f)"

PRIVILEGE="%(#.%F{red}%#%f.%F{#4db380}>%f)"

CMD_FONT="%F{#cad6ff}"

export PROMPT="${TIME} ${WORK_DIR}${EXIT_CODE}${PRIVILEGE}${CMD_FONT}"
