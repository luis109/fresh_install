#!/usr/bin/env bash

source utils.sh

SSH_KEY_PATH=$dir/ssh_keys
SHELL_CONFIG_PATH=$dir/shell_config

STARTUP_SCRIPT_PATH=$dir/startup

MEDIA_SERVER_BACKUP=$dir/media_server
MEDIA_DISK_MOUNTPOINT=/media/Fat_Man
MEDIA_SERVER_MEDIADIR=$MEDIA_DISK_MOUNTPOINT/media
MEDIA_SERVER_USERDIR=~/docker

LINKS_SPOTIFY_KEY=https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg

## --------------------------------------------------------  ##
## --------------------------------------------------------  ##

disable_keypress
echoSection "Running script $PRG"
echoInfo "This script will fresh install applications and set up media server"\
" and workspace\n"\
"logging to $LOGFILE the command events (not the commands output)\n"
echoNote "Before running make sure the \"Fat_Man\" disk mountpoint is set to:"\
" $MEDIA_DISK_MOUNTPOINT \n"\
"by using the Disks utility.\n"
echoNote "Also ensure the following paths have the necessary files:"
echoInfo "\n- SSH keys: $SSH_KEY_PATH"
[[ ! -z "$(ls -A $SSH_KEY_PATH)" ]]\
  || echoError "    NOK"\
  && echoOk "    OK"
echoInfo "\n- Shell configuration files: $SHELL_CONFIG_PATH"
[[ ! -z "$(ls -A $SHELL_CONFIG_PATH)" ]]\
  || echoError "    NOK"\
  && echoOk "    OK"
echoInfo "\n- Startup scripts: $STARTUP_SCRIPT_PATH"
[[ ! -z "$(ls -A $STARTUP_SCRIPT_PATH)" ]]\
  || echoError "    NOK"\
  && echoOk "    OK"
echoInfo "\n- Media server backup: $MEDIA_SERVER_BACKUP"
[[ ! -z "$(ls -A $MEDIA_SERVER_BACKUP)" ]]\
  || echoError "    NOK"\
  && echoOk "    OK"
echoNote "Also ensure the following links are correct:"
echoInfo "\n- Spotify key: $LINKS_SPOTIFY_KEY"
check_url_ret_200_or_302 "$LINKS_SPOTIFY_KEY"\
   || echoError "    NOK - $LINKS_SPOTIFY_KEY"\
   && echoOk "    OK"
enable_keypress
echoWar "\nProceed (It will create errors if are any errors detected with the versions, look for NOK)?"
wait_for_keypress


## --------------------------------------------------------  ##
## --------------------------------------------------------  ##
echoSection "OpenSSH"
apt_install openssh-server

## --------------------------------------------------------  ##
echoSection "SSH keys"
echoInfo "Seting up ssh keys"
mkdir -p ~/.ssh
cp -vr $SSH_KEY_PATH/* ~/.ssh
eval "$(ssh-agent -s)"
ssh-add $(grep -slR "PRIVATE" ~/.ssh/)

## --------------------------------------------------------  ##
echoSection "Htop"
apt_install htop

## --------------------------------------------------------  ##
echoSection "Tldr"
apt_install npm
sudo npm install -g tldr

## --------------------------------------------------------  ##
echoSection "Keepassxc"
apt_install keepassxc

## --------------------------------------------------------  ##
echoSection "OpenVPN"
apt_install openvpn

## --------------------------------------------------------  ##
echoSection "Comms"
echoInfo "Discord"
wget_install_deb "Discord" "https://discord.com/api/download?platform=linux&format=deb"

## --------------------------------------------------------  ##
echoSection "Browsers"
apt_install libxss1 libappindicator1 libindicator7
echoInfo "Google Chrome"
wget_install_deb "chrome" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

## --------------------------------------------------------  ##
echoSection "Games"
echoInfo "Steam"
wget_install_deb "Steam" "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"

## --------------------------------------------------------  ##
echoSection "Spotify"
curl -sS $LINKS_SPOTIFY_KEY | sudo apt-key add - 
echoIfError "Error setting up spotify gpg key"
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
echoIfError "Error setting up spotify repository"
sudo apt update -y
apt_install spotify-client
echoNote "Finished Spotify"

## --------------------------------------------------------  ##
echoSection "Docker"
# apt_install docker docker.io docker-compose
# sudo usermod -aG docker ${USER}
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
echoIfError "Error installing Docker"
echoNote "Finished Docker"

## --------------------------------------------------------  ##
echoSection "Editors"
echoInfo "VSCode"
wget_install_deb "VSCode" "https://go.microsoft.com/fwlink/?LinkID=760868"
echoInfo "VSCode plugins"
#code --list-extensions
for plg in eamodio.gitlens ms-vscode.cpptools platformio.platformio-ide ryu1kn.partial-diff;
do
  echoOk "Install VSCode plugin $plg"
  code --install-extension $plg
  echoIfError "Error installing VSCode plugin $plg"
done
echoInfo "VSCode settings"
echo '{' >  ~/.config/Code/User/settings.json \
  && echo '    "window.zoomLevel": 2,' >> ~/.config/Code/User/settings.json \
  && echo '    "editor.rulers": [80]' >> ~/.config/Code/User/settings.json \
  && echo '}' >> ~/.config/Code/User/settings.json
echoIfError "Error setting out .settings for VSCode"
echoInfo "SED"
apt_install sed

## --------------------------------------------------------  ##
echoSection "Development"
echoInfo "Git"
apt_install git
echoInfo "Gitkraken"
wget_install_deb "Gitkraken" "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
echoInfo "C++"
apt_install build-essential cmake 
echoInfo "Java"
apt_install openjdk-11-jdk openjdk-11-jre ant
echoInfo "Python"
apt_install python3 python-is-python3
apt_install sphinx-doc sphinx-common

## --------------------------------------------------------  ##
echoSection "Network"
apt_install nmap netcat

## --------------------------------------------------------  ##
echoSection "Electrical"
echoInfo "Cutecom"
apt_install cutecom
echoInfo "KiCad"
sudo add-apt-repository ppa:kicad/kicad-7.0-releases
sudo apt update
sudo apt install -y --no-install-recommends kicad
echoIfError "Error installing kicad"
mkdir -p ~/kicad && cd ~/kicad
echoInfo "Setting up KiCad Symbols"
git clone https://gitlab.com/kicad/libraries/kicad-symbols.git
echoIfError "Error setting up KiCad Symbols"
echoInfo "Setting up KiCad Footprints"
git clone https://gitlab.com/kicad/libraries/kicad-footprints.git
echoIfError "Error setting up KiCad Footprints"
echoInfo "Setting up KiCad 3D Packages"
git clone https://gitlab.com/kicad/libraries/kicad-packages3D.git
echoIfError "Error setting up KiCad 3D Packages"
echoInfo "Setting up KiCad Footprint Generator"
git clone https://gitlab.com/kicad/libraries/kicad-footprint-generator.git
echoIfError "Error setting up KiCad Footprint Generator"
cd $dir

## --------------------------------------------------------  ##
echoSection "Ocamlfuse"
wait_for_keypress
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
apt_install google-drive-ocamlfuse
mkdir -p ~/gdrive
google-drive-ocamlfuse ~/gdrive 

## --------------------------------------------------------  ##
echoSection "Shell Config"
echoInfo "Tmux"
apt_install tmux
echoInfo "Tmux Themes"
if [[ ! -d ~/.local/tmux-theme ]]; then
  mkdir ~/.local/tmux-theme
fi
git clone "https://github.com/wfxr/tmux-power.git" ~/.local/tmux-theme/tmux-power/
echoIfError "Error installing tmux themes"
echoInfo "Setting Tmux as default shell"
chsh -s $(which tmux)
echoIfError "Error setting tmux as default shell"
echoInfo "Copying shell configurations"
cp -v $SHELL_CONFIG_PATH/.bash* $SHELL_CONFIG_PATH/.tmux* ~/
echoIfError "Error copying shell config scripts"

## --------------------------------------------------------  ##
echoSection "Systemd Script"
sudo cp $STARTUP_SCRIPT_PATH/my_start.service /etc/systemd/system
cp $STARTUP_SCRIPT_PATH/my_start_script.sh ~/
echoIfError "Error copying scripts"
sudo chmod 644 /etc/systemd/system/my_start.service
sudo systemctl enable my_start.service
echoIfError "Error setting up systemd service"
echoNote "Finished setting up systemd service"

## --------------------------------------------------------  ##
## --------------------------------------------------------  ##
echoSection "Media Server"
echoInfo "Setting up Environment"
ENVFILE="/etc/environment"
sudo sh -c "echo '' >> $ENVFILE"
sudo sh -c "echo '' >> $ENVFILE"
# User ID and system time
sudo sh -c "echo 'PUID=1000' >> $ENVFILE"
sudo sh -c "echo 'PGID=1000' >> $ENVFILE"
sudo sh -c "echo 'TZ=\"Europe/Lisbon\"' >> $ENVFILE"
# Paths
sudo sh -c "echo 'USERDIR=\"${MEDIA_SERVER_USERDIR}\"' >> $ENVFILE"
sudo sh -c "echo 'MEDIADIR=\"${MEDIA_SERVER_MEDIADIR}\"' >> $ENVFILE"
# Install
echoIfError "Error setting up environment"
echoInfo "Installing media server files"
mkdir -p ~/docker
cp -vr $MEDIA_SERVER_BACKUP/* ~/docker
echoIfError "Error Installing server files"
sudo chown -R ${USER}:${USER} ~/docker
echoIfError "Error setting up file owership"
echoNote "Finished installing Media Server"


## --------------------------------------------------------  ##
## --------------------------------------------------------  ##
echoSection "Setup repos"

echoOk "Checking out Neptus"
mkdir -p ~/workspace/neptus/develop && cd ~/workspace/neptus \
  && git clone https://github.com/LSTS/neptus.git develop
echoIfError "Error cheking out Neptus"

cd $dir
echoOk "Checking out DUNE"
mkdir -p ~/workspace/dune/dune && cd ~/workspace/dune \
  && git clone git@github.com:luis109/dune.git dune
echoIfError "Error cheking out DUNE"
mkdir -p ~/workspace/dune/dune/private && cd ~/workspace/dune \
  && mkdir -p ~/workspace/dune/dune/.vscode \
  && git clone ssh://git@git.lsts.pt:443/LSTS/dune-private.git dune/private
echoIfError "Error cheking out DUNE private"
echo '{' >  ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '    "configurations": [' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '        {' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "name": "Linux",' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "includePath": [' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '                "${workspaceFolder}/**", "${workspaceFolder}/../build/DUNEGeneratedFiles/src",' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '                "${workspaceFolder}/src"' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            ],' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "defines": [],' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "compilerPath": "/usr/bin/gcc",' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "cStandard": "c11",' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "cppStandard": "c++14",' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '            "intelliSenseMode": "clang-x64"' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '        }' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '    ],' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '    "version": 4' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json \
  && echo '}' >> ~/workspace/dune/dune/.vscode/c_cpp_properties.json
echoIfError "Error setting out .vscode for DUNE"

cd $dir
echoOk "Checking out GLUED"
mkdir -p ~/workspace/glued && cd ~/workspace/glued && git clone https://github.com/LSTS/glued.git feature/cloud
echoIfError "Error cheking out GLUED"

cd $dir
echoOk "Checking out IMC"
cd ~/workspace && git clone https://github.com/LSTS/imc.git
echoIfError "Error cheking out"

cd $dir

## --------------------------------------------------------  ##
## --------------------------------------------------------  ##
echoSection "Compiling Repos"

cd ~/workspace/neptus/develop && ./gradlew
echoIfError "Error compiling Neptus"

mkdir -p ~/workspace/dune/build && cd ~/workspace/dune/build && cmake ../dune && make -j$(nproc)
echoIfError "Error compiling DUNE"
