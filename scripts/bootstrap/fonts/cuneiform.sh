# Install Cuneiform Fonts
#--------------------------------------------------------------

# Default Cuneiform fonts display incorrectly
# Find actual ones here: https://hethport.net/cuneifont/

# Make folder
HETHPORT_FONT_DIR="$HOME/.local/share/fonts/hethport_cuneiform"
mkdir -p "$HETHPORT_FONT_DIR"

# Download zips
for url in \
    "https://hethport.net/cuneifont/download/Santakku.zip" \
    "https://hethport.net/cuneifont/download/Ullikummi.zip" \
    "https://hethport.net/cuneifont/download/OldPersian.zip"
do
    curl -fsSL "$url" -o /tmp/font.zip && unzip -j /tmp/font.zip "*.ttf" -d "$HETHPORT_FONT_DIR" && rm /tmp/font.zip
done

# Download ttf
curl -fsSL "https://hethport.net/cuneifont/download/Assurbanipal.ttf" -o "$HETHPORT_FONT_DIR/Assurbanipal.ttf"
curl -fsSL "https://hethport.net/cuneifont/download/Esagil.ttf" -o "$HETHPORT_FONT_DIR/Esagil.ttf"

# Register fonts
fc-cache -fv "$HETHPORT_FONT_DIR"

