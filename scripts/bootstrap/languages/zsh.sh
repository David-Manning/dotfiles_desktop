### Install ZSH
#--------------------------------------------------------------

set -euo pipefail

sudo dnf install -y \
	zsh \
	zsh-syntax-highlighting

# The login shell is not changed here because chsh asks for a password
# Run chsh -s /usr/bin/zsh by hand after the bootstrap - see README
