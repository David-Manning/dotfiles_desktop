# Installation on Windows

## Install Software

In Powershell, install basic software from winget:
```
winget install `
    Neovim.Neovim `
    glzr-io.glazewm `
    glzr-io.zebar `
    Flow-Launcher.Flow-Launcher `
    JuliaLang.Juliaup `
    Rustlang.Rustup `
    RProject.R `
    RProject.Rtools `
    Python.Python.3.14 `
    RubyInstallerTeam.Ruby.3.4 `
    7zip.7zip `
    Alacritty.Alacritty `
    Microsoft.VisualStudio.2022.BuildTools `
    Git.Git `
    OpenJS.NodeJS `
    Amazon.AWSCLI `
    Amazon.SAM-CLI `
    eza-community.eza `
    YS-L.csvlens
```

Install R packages. 
Note that rstan is necessary for Stan syntax checking to work in Neovim.
```
Rscript -e "install.packages(c(
    'tidyverse', 'data.table', 'readr', 'readxl', 'readbulk', 'openxlsx', 'lubridate',
    'brms', 'bayesplot', 'shinystan', 'tidybayes', 'loo', 'SHELF', 'BACCO', 'calibrator', 'rstan',
    'caret', 'xgboost', 'randomForest', 'rBayesianOptimization',
    'forecast', 'bsts', 'zoo', 'slider',
    'lme4', 'mice', 'mixtools', 'moments', 'extraDistr', 'transport', 'philentropy', 'emdist',
    'ggfortify', 'latex2exp', 'igraph',
    'PlackettLuce', 'elo',
    'FNN', 'dbscan', 'geodist',
    'aws.s3', 'paws', 'RMySQL', 'DATAstudio',
    'devtools', 'languageserver', 'reticulate', 'parallelly', 'RcppEigen', 'BH'
), repos='https://cloud.r-project.org')"
```

Install tree-sitter-cli:

```
npm install -g tree-sitter-cli
```

Install Cargo:

```
cargo install rainfrog
```

## Create folder and clone repo
```
mkdir ~/software
git clone https://github.com/David-Manning/dotfiles_desktop ~\software\dotfiles_desktop
```

## Create Symlinks
This tells Windows to use the links in this repo, rather than the default.
This requires admin rights.
```
New-Item -ItemType SymbolicLink -Path ~\.config\nvim -Target ~\software\dotfiles_desktop\config\nvim
New-Item -ItemType SymbolicLink -Path ~\.glzr\glazewm -Target ~\software\dotfiles_desktop\config\glazewm
New-Item -ItemType SymbolicLink -Path ~\.glzr\zebar -Target ~\software\dotfiles_desktop\config\zebar
New-Item -ItemType SymbolicLink -Path ~\.config\gh -Target ~\software\dotfiles_desktop\config\gh
New-Item -ItemType SymbolicLink -Path ~\.config\alacritty -Target ~\software\dotfiles_desktop\config\alacritty
```

## Sync Lazy.nvim
This can be done by opening neovim but it is easier to run here than interactively.
```
nvim --headless "+Lazy! sync" +qa
```

