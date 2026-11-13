# Install File Manager
#--------------------------------------------------------------

set -euo pipefail

sudo dnf remove -y \
	thunar
sudo dnf install -y dolphin

