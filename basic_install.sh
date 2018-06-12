#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

## First things first: update
system_update () {
    #TODO: add check if yaourt installed then use that
    echo ''
    echo '############################'
    echo '## Performing full update ##'
    echo '############################'
    echo ''
    if hash yaourt 2>/dev/null; then
        echo ''
        echo 'yaourt installed. Using yaourt'
        echo ''
        yaourt -Syua
    else
        echo ''
        echo 'yaourt not installed. Using pacman'
        echo ''
        sudo pacman -Syu --noconfirm
    fi

    execution
}


## Prepare for yaourt installation
install_yaourt () {
  echo ''
  echo '#######################'
  echo '## Installing yaourt ##'
  echo '#######################'
  echo ''
  mkdir /tmp/yaourt_inst
  cd /tmp/yaourt_inst

  ## install package-query
  curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
  tar -xvzf package-query.tar.gz
  cd package-query
  makepkg -si

  cd ..

  ## install yaourt
  curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
  tar -xvzf yaourt.tar.gz
  cd yaourt
  makepkg -si

  ## cleanup
  cd /
  rm -R /tmp/yaourt_inst

  execution
}

## Install needed apps via yaourt_inst
## TODO: make apps checkable
install_apps () {
  echo ''
  echo '################################'
  echo '## Installing additional apps ##'
  echo '################################'
  echo ''
  yaourt -S --noconfirm \
      visual-studio-code \
      intellij-idea-ultimate-edition \
      solaar \
      terminator \
      git \
      vim \
      zsh \
      firefox \
      libreoffice-still \
      gimp \
      docker \
      mc \
      adobe-source-code-pro-fonts \
      ttf-mononoki \
      gtk-theme-arc-git \
      papirus-icon-theme-git \
      openssh \
      smartgit \
      rocketchat-client-bin \
      flashplugin \
      nodejs \
      npm \
      keepassxc \
      gpaste \
      etcher \
      teamviewer \
      postman \
      spotify \

  execution
}

## Registering additional modules to load on startup
enable_modules () {
  echo ''
  echo '###############################'
  echo '## Enable additional modules ##'
  echo '###############################'
  echo ''
  sudo systemctl enable NetworkManager docker sshd
  sudo systemctl start NetworkManager docker sshd

  execution
}

## Install and configure oh-my-zsh
install_OMZSH () {
  echo ''
  echo '##########################'
  echo '## Installing oh-my-zsh ##'
  echo '##########################'
  echo ''
  cd ~/
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' ~/.zshrc
  echo Adding alias file
  #TODO Copy command not working -> how to copy file from script path
  cp $BASEDIR/aliases ~/.aliases
  echo source ~/.aliases >> ~/.zshrc

  execution
}

## Moving window buttons
set_theming () {
  echo ''
  echo '#################################'
  echo '## Setting theme and behaviour ##'
  echo '#################################'
  echo ''
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:'
  gconftool-2 --set /apps/metacity/general/button_layout --type string "close,maximize,minimize:"
  gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
  gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Dark'
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro Semi-Bold 11'
  gsettings set org.gnome.desktop.interface font-name 'mononoki 11'

  cp $BASEDIR/vimrc ~/.vimrc

  execution
}

## Set and change some shortcuts
set_shortcuts () {
  echo ''
  echo '######################'
  echo '## Adding shortcuts ##'
  echo '######################'
  echo ''
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Super><Shift>Up']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Super><Shift>Down']"

  execution
}

## Perform a full install
full_install () {
  system_update
  install_yaourt
  install_apps
  enable_modules
  install_OMZSH
  set_theming
}

## Print choices and perform execution
execution () {
  echo ''
  echo '#################################'
  echo '## Arch Personalization Script ##'
  echo '#################################'
  echo ''
  echo 'Please choose what to do:'
  echo '-----------------------------------'
  echo ' 0 -> Perform all tasks in order.'
  echo ' 1 -> System update'
  echo ' 2 -> Install yaourt'
  echo ' 3 -> Install apps'
  echo ' 4 -> Register additional modules'
  echo ' 5 -> Install oh-my-zsh'
  echo ' 6 -> Change theming'
  echo ' 7 -> Set shortcuts'
  echo ' 8 -> install Gnome Shell extensions'
  echo '------------------------------------'

  read choice

  case $choice in
      0) full_install;;
      1) system_update;;
      2) install_yaourt;;
      3) install_apps;;
      4) enable_modules;;
      5) install_OMZSH;;
      6) set_theming;;
      7) set_shortcuts;;
      8) install_gnome_extensions;;
      *) echo 'Wrong choice'
  esac
}

execution
