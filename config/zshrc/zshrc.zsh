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


# Source individual functions
source $HOME/.config/zshrc/functions_aws/aws_login_sso.zsh
source $HOME/.config/zshrc/functions_github/create_github_repo.zsh
source $HOME/.config/zshrc/functions_github/ssh_github.zsh
source $HOME/.config/zshrc/functions_help/help_spotify_player.zsh
source $HOME/.config/zshrc/functions_help/help_zsh.zsh
source $HOME/.config/zshrc/functions_latex/latex_view.zsh
source $HOME/.config/zshrc/functions_latex/latex_compile.zsh
source $HOME/.config/zshrc/functions_other/hugo_test.zsh
source $HOME/.config/zshrc/functions_other/list_files.zsh
source $HOME/.config/zshrc/functions_other/shutdown_update.zsh
source $HOME/.config/zshrc/functions_other/source_zsh.zsh

# Source syntax highlighting - MUST be at the bottom
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Print a welcome message and list of aliases
echo "Welcome to Fedora!"
echo "For a list of custom zsh functions run command zsh_help"
echo 
