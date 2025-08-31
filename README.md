# My Dotfiles

These are my dotfiles for Fedora Linux with Sway window manager. They work for me and my workflow. They may not work for you and your workflow. Dotfiles are very personal. I recommend against copying anyone's dotfiles directly and in favour of looking at the screenshots, reading the files, and deciding what would work for you. I also recommend looking at other people's dotfiles and see how they solve the same problems.

## Installation

The files are set up in `~/software/dotfiles/config`

### Cloning the repo

```bash
mkdir -p ~/software
git clone https://github.com/David-Manning/dotfiles ~/software/dotfiles
```

### Create Symlinks

These files should be in `~/.config`, but are actually in `~/software/dotfiles`, so set up symlinks to tell Linux where the files are.
Some symlinks will fail if the target directories already exist.

```bash
ln -s ~/software/dotfiles/config/nvim ~/.config/nvim
ln -s ~/software/dotfiles/config/waybar ~/.config/waybar
ln -s ~/software/dotfiles/config/swaylock ~/.config/swaylock
ln -s ~/software/dotfiles/config/foot ~/.config/foot
ln -s ~/software/dotfiles/config/sway ~/.config/sway
ln -s ~/software/dotfiles/config/zshrc ~/.config/zshrc
ln -s ~/software/dotfiles/config/dunst ~/.config/dunst
ln -s ~/software/dotfiles/config/kitty ~/.config/kitty
ln -s ~/software/dotfiles/config/rofi ~/.config/rofi
ln -s ~/software/dotfiles/config/yazi ~/.config/yazi
ln -s ~/software/dotfiles/config/gh ~/.config/gh
ln -s ~/software/dotfiles/config/mimeapps.list ~/.config/mimeapps.list
ln -s ~/software/dotfiles/config/discord ~/.config/discord
```

Also remove `~/.zshrc` and symlink to the .zshrc file in the repo.

```bash
rm ~/.zshrc
ln -s ~/software/dotfiles/.zshrc ~/.zshrc
```

### Optional Dependencies

For full functionality, ensure the following are installed. This should not cause major issues but will make some features not work and some fonts not display (including emojis).

* R (Fedora: `sudo dnf install R`)
* rstan (R package)
* pdflatex (Fedora: `sudo dnf install texlive`)
* Roboto Mono font for Sway title bar (Fedora: `sudo dnf install roboto-mono-nerd-fonts`)
* JetBrainsMono Nerd Font for terminal (Fedora: `sudo dnf install jet-brains-mono-nerd-fonts`)
* Twemoji for terminal emojis (Fedora: `sudo dnf install twitter-twemoji-fonts`) 

## Licence

This project is licensed under the MIT Licence - see the [LICENSE](LICENSE) file for details.


