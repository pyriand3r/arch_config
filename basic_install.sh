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
      networkmanager \
      network-manager-applet \
      atom \
      solaar \
      terminix \
      git \
      vim \
      zsh \
      redshift \
      firefox \
      firefox-i18n-de \
      libreoffice-still \
      calibre \
      gimp \
      rapid-photo-downloader \
      docker \
      mc \
      gst-plugins-ugly \
      adobe-source-code-pro-fonts \
      gtk-theme-arc-git \
      paper-icon-theme-git \
      gnome-shell-extension-installer \
      openssh \
      wine

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
  gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'alternate-tab@gnome-shell-extensions.gcampax.github.com', 'apps-menu@gnome-shell-extensions.gcampax.github.com']"
  gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
  gsettings set org.gnome.desktop.interface icon-theme 'Paper'
  gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Dark'
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro Semi-Bold 11'

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

## Install additional gnome extensions
install_gnome_extensions () {
  echo ''
  echo '####################################################'
  echo '## Which extensions would you like me to install? ##'
  echo '####################################################'
  echo ''
  echo '  1 -> caffeine'
  echo '  2 -> media player indicator'
  echo '  3 -> no top-left hot corner'
  echo '  4 -> shutdown timer'
  echo '  5 -> dim on battery'
  echo '  6 -> do not disturb button'
  echo '  7 -> todo.txt'
  echo '  8 -> docker integration'
  echo '  9 -> top icons plus'
  echo ' 10 -> services systemd'
  echo ' 11 -> shellshape'
  echo ' 12 -> system monitor'
  echo ' 13 -> extensions'
  echo ' 14 -> sound input-output chooser'
  echo ' 15 -> dash to dock'
  echo ' 16 -> multi monitor add-on'
  echo ' 17 -> jenkins ci indicator'
  echo ''

  read choices

  list=$(echo $choices | tr " " "\n")
  installerArgs="--yes --restart-shell"

  for extension in $list
  do
    case $extension in
      1) installerArgs="$installerArgs 517";;
      2) installerArgs="$installerArgs 55";;
      3) installerArgs="$installerArgs 118";;
      4) installerArgs="$installerArgs 792";;
      5) installerArgs="$installerArgs 947";;
      6) installerArgs="$installerArgs 964";;
      7) installerArgs="$installerArgs 570";;
      8) installerArgs="$installerArgs 1055";;
      9) installerArgs="$installerArgs 1031";;
      10) installerArgs="$installerArgs 1034";;
      11) installerArgs="$installerArgs 294";;
      12) installerArgs="$installerArgs 1064";;
      13) installerArgs="$installerArgs 1036";;
      14) installerArgs="$installerArgs 906";;
      15) installerArgs="$installerArgs 307";;
      16) installerArgs="$installerArgs 921";;
      17) installerArgs="$installerArgs 399";;
      *) ;;
    esac
  done

  gnome-shell-extension-installer $installerArgs

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
  set_shortcuts
  install_gnome_extensions
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
