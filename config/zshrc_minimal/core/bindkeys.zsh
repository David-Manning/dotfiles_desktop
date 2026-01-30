#------------------------------------------------
# ZSHRC BINDKEYS
#------------------------------------------------

# Fixes issues with home, end, delete keys not acting as they should

# Stop delete key producing a ~
bindkey "^[[3~" delete-char

# Home and end keys go to start and end of line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# CTRL+left/right move one word at a time
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
