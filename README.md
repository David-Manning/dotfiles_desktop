# My Dotfiles

These are my dotfiles for Fedora Linux with Sway window manager. They work for me and my workflow. They may not work for you and your workflow. Dotfiles are very personal. I recommend against copying anyone's dotfiles directly and in favour of looking at the screenshots, reading the files, and deciding what would work for you. I also recommend looking at other people's dotfiles and see how they solve the same problems.

## Details

* **OS**: [Fedora](https://www.fedoraproject.org)
* **Window manager**: [Sway](https://www.github.com/swaywm/sway)
* **Status bar**: [Waybar](https://www.github.com/Alexays/Waybar)
* **Notifications**: [Dunst](https://www.github.com/dunst-project/dunst)
* **Terminal**: [Foot](https://www.codeberg.org/dnkl/foot)
* **Editor**: [Neovim](https://www.github.com/neovim/Neovim)
* **IDE**: None
* **File manager**: [Yazi](https://www.github.com/sxyyazi/yazi)
* **Spotify client**: [spotify_player](https://www.github.com/aome510/spotify-player)
* **Browser**: Firefox
* **DB Client**: [Rainfrog](https://github.com/achristmascarl/rainfrog)
* **CSV Reader**: [csvlens](https://www.github.com/YS-L/csvlens)

## Screenshots

Basic state:
<img src="assets/screenshots/desktop_default.png" alt="Desktop Default" width="800">


Status bar:
<img src="assets/screenshots/status_bar.png" alt="Status Bar" width="800">

The date is centred on screen but appears off-centre here to keep all elements readable.

## Installation

The files are set up in `~/software/dotfiles_desktop/config`

### Install GitHub

Everything is saved and linked to GitHub.

Install gh (GitHub client):

```bash
sudo dnf install gh -y
```

Run this to create auth tokens (it will automatically open a browser to authenticate):
```bash
gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
```

### Install dotfiles

Backup first
```bash
mkdir ~/software/dotfiles_desktop_backup
cp -r ~/software/dotfiles_desktop ~/software/dotfiles_desktop_backup
```

Then clone repo
```bash
mkdir -p ~/software
git clone https://github.com/David-Manning/dotfiles_desktop ~/software/dotfiles_desktop
```

### Create Symlinks

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
```

### Optional Dependencies

The following packages are only required if you want the full Neovim experience or proper font support in your terminal and window manager.

#### Neovim
Neovim will perform a quick “dummy run” to validate the syntax of your files on save (e.g. checking for missing brackets that stop compilation).
To enable this check, you need to install the relevant languages.

Enable the CRAN repo on Fedora:
```bash
sudo dnf copr enable iucar/cran
```

After enabling the repository, install the packages:
```bash
sudo dnf install R
sudo dnf install R-CRAN-rstan
sudo dnf install texlive
```

Non-Fedora users can install rstan by running `install.packages("rstan")` directly in R.

To install treesitter, run `npm install -g tree-sitter-cli`. On Windows, you will also need to install Visual Studio Build Tools to compile C code.

#### Fonts

These fonts are used in the window title bar and in the terminal and to make emojis display in the terminal.

Install nerd fonts repo:
```bash
sudo dnf copr enable aquacash5/nerd-fonts
```

Install fonts:
```bash
sudo dnf install roboto-mono-nerd-fonts
sudo dnf install jet-brains-mono-nerd-fonts
sudo dnf install twitter-twemoji-fonts
```

#### AWS SAM CLI

I use AWS SAM CLI to develop on AWS.

```bash
curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o /tmp/aws-sam-cli.zip -sS
unzip /tmp/aws-sam-cli.zip -d /tmp/sam-installation -q
sudo /tmp/sam-installation/install
rm /tmp/aws-sam-cli.zip
rm -rf /tmp/sam-installation
sam --version
```

#### Julia
Install Julia via Juliaup:
```bash
curl -fsSL https://install.julialang.org | sh
```
Then choose "customise installation"

* Enter the folder where you want to install Juliaup: default
* Do you want to add the Julia binaries to your PATH?: no (already in custom zshrc)
* Do you want to add channel specific symlinks?: no
* Enter minutes between check for new version at julia startup: 0
* Enter minutes between check for new version by a background task: 0

## Licence

This project is licensed under the MIT Licence - see the [LICENSE](LICENSE) file for details.


