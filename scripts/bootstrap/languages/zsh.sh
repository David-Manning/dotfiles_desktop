### Install ZSH
#--------------------------------------------------------------

set -euo pipefail

sudo dnf install -y \
	zsh \
	zsh-syntax-highlighting

chsh -s $(which zsh)
