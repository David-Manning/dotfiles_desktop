# Install text editor
#--------------------------------------------------------------

set -euo pipefail

sudo dnf install -y neovim
sudo dnf remove -y \
	nano \
	emacs \
	vim

