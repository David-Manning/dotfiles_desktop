#------------------------------------------------
# ZSH PATH DEFINITION
#------------------------------------------------

# Defines path in a zsh-like way

# Ensure PATH only contains unique entries
typeset -U path

path=(
	$HOME/.local/bin
	$HOME/bin
	$HOME/go/bin
	$HOME/.cargo/bin
	$HOME/.juliaup/bin
	$path
)

export PATH
