# Installation on Ubuntu Servers

## Clone Repo
```bash
mkdir -p ~/software
git clone https://github.com/David-Manning/dotfiles_desktop.git ~/software/dotfiles_desktop
```

## Create Symlinks

These files should be in `~/.config`, but are actually in `~/software/dotfiles_desktop`, so set up symlinks to tell Linux where the files are.
Some symlinks will fail if the target directories already exist.

```bash
ln -s ~/software/dotfiles_desktop/config/nvim ~/.config/nvim
ln -s ~/software/dotfiles_desktop/config/waybar ~/.config/waybar
ln -s ~/software/dotfiles_desktop/config/swaylock ~/.config/swaylock
ln -s ~/software/dotfiles_desktop/config/foot ~/.config/foot
ln -s ~/software/dotfiles_desktop/config/sway ~/.config/sway
ln -s ~/software/dotfiles_desktop/config/dunst ~/.config/dunst
ln -s ~/software/dotfiles_desktop/config/kitty ~/.config/kitty
ln -s ~/software/dotfiles_desktop/config/rofi ~/.config/rofi
ln -s ~/software/dotfiles_desktop/config/yazi ~/.config/yazi
ln -s ~/software/dotfiles_desktop/config/mimeapps.list ~/.config/mimeapps.list
ln -s ~/software/dotfiles_desktop/config/discord ~/.config/discord
ln -s ~/software/dotfiles_desktop/config/spotify-player ~/.config/spotify-player
ln -s ~/software/dotfiles_desktop/config/rainfrog ~/.config/rainfrog
ln -s ~/software/dotfiles_desktop/config/zshrc ~/.config/zshrc
```
## Install Software from apt-get
```bash
sudo apt-get install -y \
    zsh \
    zsh-syntax-highlighting \
    r-base \
    r-base-dev \
    ruby \
    texlive \
    npm \
    tmux
```

## Install Cargo
Install Rust via Rustup:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install programs:
```bash
cargo install rainfrog 
```

## Install Neovim
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
```

## AWS SAM CLI

I use AWS SAM CLI to develop on AWS.

```bash
curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o /tmp/aws-sam-cli.zip -sS
unzip /tmp/aws-sam-cli.zip -d /tmp/sam-installation -q
sudo /tmp/sam-installation/install
rm /tmp/aws-sam-cli.zip
rm -rf /tmp/sam-installation
sam --version
```

## Minimal zshrc
**ON SERVERS ONLY**:
Link to the minimal zshrc. This is intended to be a minimal zshrc, not for desktop use.

```
ln -s ~/software/dotfiles_desktop/config/zshrc ~/.config/zshrc
rm ~/.zshrc
ln -s ~/software/dotfiles_desktop/.zshrc ~/.zshrc
```
