#------------------------------------------------
# ZSHRC BASE FILE
#------------------------------------------------

#                  _                   
#                 | |                  
#      ____  ___  | |__    _ __    ___ 
#     |_  / / __| | '_ \  | '__|  / __|
#  _   / /  \__ \ | | | | | |    | (__ 
# (_) /___| |___/ |_| |_| |_|     \___|


# .zsh file saved here in .config
#~/.zshrc sources this

# Source global definitions - default settings
if [ -f /etc/zshrc ]; then
	. /etc/zshrc
fi

# Source subscripts
source $HOME/.config/zshrc/core/env.zsh
source $HOME/.config/zshrc/core/path.zsh
source $HOME/.config/zshrc/core/bindkeys.zsh
