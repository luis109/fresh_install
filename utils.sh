#!/usr/bin/bash

# Fev 2023
# author: PDias

if [ -z "$BASH" ]
then
  bash $0 $@
fi

# save current working dir
dir=$PWD
PRG="$0"
PRG_NAME="$(basename "$PRG" | sed  's/\..*$//')"
LOGFILE="$dir/$PRG_NAME.log"

## --------------------------------------------------------  ##
NC='\033[0m' # No Color
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'

echo > $LOGFILE

function echoInfo {
  echo -e "${CYAN}$1${NC}" | tee -a "$LOGFILE"
}

function echoSection {
  echo -e "\n${CYAN}######## $1 ########${NC}" | tee -a "$LOGFILE"
}

function echoWar {
  echo -e "${YELLOW}$1${NC}" | tee -a "$LOGFILE"
}

function echoNote {
  echo -e "${MAGENTA}$1${NC}" | tee -a "$LOGFILE"
}

function echoOk {
  echo -e "${GREEN}$1${NC}" | tee -a "$LOGFILE"
}

function echoError {
  local errcode=$?
  echo -e "${RED}$1${NC}" | tee -a "$LOGFILE"
  return $errcode
}

function enable_keypress {
  unset DISABLE_WAIT_KEYPRESS
}
enable_keypress

function disable_keypress {
  DISABLE_WAIT_KEYPRESS=true
}

function wait_for_keypress {
  if [ -z ${DISABLE_WAIT_KEYPRESS+x} ] ;
  then
    echoWar "Press any key to continue or 'q' to quit or 'c' to not ask again"
    while [ -z ${DONT_STOP_ON_ERROR+x} ] ; do
      read -t 3 -n 1 k <&1
      if [ $? = 0 ] ; then
        case $k in
          c* )     export DONT_STOP_ON_ERROR=true;;
          
          q* )     exit 255;;
          
          *  )     break;;
        esac
      #else
        #echoWar "waiting for the keypress (any to continue, 'q' to quit or 'c' to not ask again)"
      fi
    done
  fi
}

function echoIfError {
  local errcode=$?
  if [ $errcode -ne 0 ]; then
    echo -e "${RED}$1 [Error code ${YELLOW}${errcode}${RED}]${NC}" | tee -a "$LOGFILE"
    wait_for_keypress
  fi
  return $errcode
}

function apt_install {
  echoInfo "Installing: $@"
	for pkt in $@;
	do
    echoOk "Install $pkt"
	  sudo apt install -y $pkt
    echoIfError "!!! Fail apt installing $pkt !!!"
    echoNote "Finish installing $pkt"
	done
}

function wget_install_deb {
  echoNote "Downloading $1"
  local FILE_PATH=~/Downloads/$1.deb
  wget -O $FILE_PATH $2 && apt_install $FILE_PATH #&& rm -f $FILE_PATH
  echoIfError "!!! Fail downloading $1 !!!"
}

function download_from_drive {
  local filename=$1 # xp4-aux-data0.tar.gz
  local fileid=$2 # 17y4OhSqRflCy3GIZjAk42mYuNSJIMFUR
  # Note some old gdrive share folder gives error downloading
  # If "Get Link" is of the form:
  #  - https://drive.google.com/file/d/0ByeXezPbdIZjdk1xdlRzWENEVEk/view?usp=share_link&resourcekey=0-YptJIQc1IX8vDSd4ts8rKg
  # Reupload it again. This new file will have the "Get Link" that works like:
  #  - https://drive.google.com/file/d/1UK19o5fkO6-n8PV6TmgyhhBA-l3MnrGP/view?usp=sharing

  echoOk "Downloading from GDrive $1"

  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
    | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt \
    && wget --load-cookies cookies.txt -O "$filename"  \
    'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  echoIfError "!!! Fail downloading $1 !!!"
  local errorcode=$?
  echoNote "Finish downloading from GDrive $1"
  return $errorcode
}

function add_to_path_in_profile {
  echoOk "Adding '$1' to /etc/profile"
  export PATH=$PATH:"$1"
  sudo bash -c "echo -e '\nexport PATH=\$PATH:\"'$1'\"' >> /etc/profile"
  echoIfError "Fail adding to /etc/profile of $1 !!!"
  return $?
}

function check_apt_exists {
  local package=$1
  local pattern_alternatives=$2

  apt list $package 2>/dev/null | grep -w "$package" >/dev/null
  echoIfError "Package $package is not found! (Use 'apt list $pattern_alternatives' to check alternatives)"
  return $?
}

function check_url_ret_200_or_302 {
  local url=$1

  local status=$(curl -o /dev/null -u myself:XXXXXX -Isw '%{http_code}\n' $url)
  [ $status -eq 200 ] || [ $status -eq 302 ]
  echoIfError "URL $url is not found!"
  return $?
}
