# Install ConScript Fonts
#--------------------------------------------------------------

# Constructed scripts (Tengwar, Klingon, Sitelen Pona, etc.) are not in Unicode
# They use Private Use Area code points agreed by the UCSUR
# Registry here: https://www.kreativekorp.com/ucsur/
# Fonts here: https://github.com/kreativekorp/open-relay (OFL)

# Fairfax HD   - monospace, for terminals
# Constructium - proportional serif, for documents and browsers

# Make folder
CONSCRIPT_FONT_DIR="$HOME/.local/share/fonts/conscripts"
mkdir -p "$CONSCRIPT_FONT_DIR"

# Download ttf
curl -fsSL "https://raw.githubusercontent.com/kreativekorp/open-relay/master/FairfaxHD/FairfaxHD.ttf" -o "$CONSCRIPT_FONT_DIR/FairfaxHD.ttf"
curl -fsSL "https://raw.githubusercontent.com/kreativekorp/open-relay/master/Constructium/Constructium.ttf" -o "$CONSCRIPT_FONT_DIR/Constructium.ttf"

# Register fonts
fc-cache -fv "$CONSCRIPT_FONT_DIR"

