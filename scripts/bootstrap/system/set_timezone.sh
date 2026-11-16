# Set timezone and enable network time synchronisation
#--------------------------------------------------------------

set -euo pipefail

sudo timedatectl set-timezone Europe/London
sudo timedatectl set-ntp true
