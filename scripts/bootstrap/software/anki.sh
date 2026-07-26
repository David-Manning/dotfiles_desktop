### Install Anki
#--------------------------------------------------------------

# Find URL for latest version
ANKI_URL=$(curl -s https://api.github.com/repos/ankitects/anki/releases/latest \
    | grep -oP '"browser_download_url": "\K[^"]+linux-x86_64\.tar\.zst(?=")')

# Target locations
ANKI_ARCHIVE=$(basename "$ANKI_URL")
ANKI_DIR="${ANKI_ARCHIVE%.tar.zst}"

# Install
curl -L -o "/tmp/${ANKI_ARCHIVE}" "$ANKI_URL"
tar xaf "/tmp/${ANKI_ARCHIVE}" -C /tmp
sudo /tmp/"${ANKI_DIR}"/install.sh

# Delete files
rm "/tmp/${ANKI_ARCHIVE}"
rm -rf "/tmp/${ANKI_DIR}"
