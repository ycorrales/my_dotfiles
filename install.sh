#! /usr/bin/env bash
(

  function _config_myMac()
  {
    echo "MacOS operating system found. Configuring Mac..."
    sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server \
      AllowGuestAccess -bool NO
    sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED \
      -bool FALSE
  }

  function Main()
  {
    DOTFILES=${DOTFILES:-"$( cd "$( dirname $(readlink -f "${BASH_SOURCE[0]}") && pwd )" > /dev/null 2>&1 && pwd )"}

    if test $OSTYPE = "darwin"*; then
      OS="osx_x86-64"
    elif test $OSTYPE = "linux-gnu"; then
      OS="linux"
    else
      OS="unkonw"
    fi

    # sourcing script to create the symbolic link
    files=( "install/link.sh $1" )
    for file in ${files[@]}; do
      FILE_PATH=${DOTFILES}/$file
      [ -f ${FILE_PATH} ] && source "$FILE_PATH"
    done
    [ $OS = "osx_x86-64" ] && _config_myMac || :
  }

  if [ $# -gt 1 ]; then
    echo "ERROR $(basename $0) accepts at max one option "
    exit -1
  fi

  Main $@
)
