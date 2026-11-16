#!/usr/bin/env bash

# Bootstrap script
#---------------------------------------------------------------

# This installs dotfiles on Fedora
# Dependency on Fedora Sway spin

# Abort if anything fails and report which script failed
set -euo pipefail
trap 'echo "Bootstrap failed in: $BASH_COMMAND"' ERR

# Define folders
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/scripts/bootstrap"

# Set up symlinks first - they depend on nothing else
# If a later script fails, the configs are still in place
bash "$BOOTSTRAP_DIR/symlinks/symlinks.sh"

# System files (future proofing)
# Printer setup is disabled - run the script by hand if needed
# bash "$BOOTSTRAP_DIR/system/printer.sh"

# Install languages
bash "$BOOTSTRAP_DIR/languages/R.sh"
bash "$BOOTSTRAP_DIR/languages/go.sh"
# Julia is disabled - run the script by hand if needed
# bash "$BOOTSTRAP_DIR/languages/julia.sh"
bash "$BOOTSTRAP_DIR/languages/latex.sh"
bash "$BOOTSTRAP_DIR/languages/python.sh"
bash "$BOOTSTRAP_DIR/languages/rust.sh"
bash "$BOOTSTRAP_DIR/languages/zsh.sh"

# rustup installs cargo into ~/.cargo/bin, which is not on the PATH of this shell
# Add it here so the scripts below that call cargo can find it
export PATH="$HOME/.cargo/bin:$PATH"

# Install software
bash "$BOOTSTRAP_DIR/software/anki.sh"
bash "$BOOTSTRAP_DIR/software/file_manager.sh"
bash "$BOOTSTRAP_DIR/software/password_manager.sh"
bash "$BOOTSTRAP_DIR/software/terminal.sh"
bash "$BOOTSTRAP_DIR/software/text_editor.sh"
bash "$BOOTSTRAP_DIR/software/video_editor.sh"
bash "$BOOTSTRAP_DIR/software/video_player.sh"

# Install CLI tools
bash "$BOOTSTRAP_DIR/cli_tools/csvlens.sh"
bash "$BOOTSTRAP_DIR/cli_tools/duckdb.sh"
bash "$BOOTSTRAP_DIR/cli_tools/file_tools.sh"
bash "$BOOTSTRAP_DIR/cli_tools/rainfrog.sh"

# Install cloud tools
bash "$BOOTSTRAP_DIR/cloud/aws_cli.sh"
bash "$BOOTSTRAP_DIR/cloud/aws_sam_cli.sh"

# Install fonts
bash "$BOOTSTRAP_DIR/fonts/conscripts.sh"
bash "$BOOTSTRAP_DIR/fonts/cuneiform.sh"
bash "$BOOTSTRAP_DIR/fonts/terminal.sh"






