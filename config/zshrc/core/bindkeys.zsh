#------------------------------------------------
# ZSHRC BINDKEYS
#------------------------------------------------

# Fixes issues with home, end, delete keys not acting as they should

# Stop delete key producing a ~
bindkey "^[[3~" delete-char

# Stop page up/down producing a ~
bindkey -s "^[[5~" ""
bindkey -s "^[[6~" ""

# Stop function keys producing a ~
bindkey -s "^[[15~" ""  # F5
bindkey -s "^[[17~" ""  # F6
bindkey -s "^[[18~" ""  # F7
bindkey -s "^[[19~" ""  # F8
bindkey -s "^[[21~" ""  # F10
bindkey -s "^[[23~" ""  # F11
bindkey -s "^[[24~" ""  # F12

# Home and end keys go to start and end of line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# CTRL+left/right move one word at a time
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
