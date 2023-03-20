#!/usr/bin/env bash

source utils.sh

SSH_KEY_PATH=$dir/ssh_keys
SHELL_CONFIG_PATH=$dir/shell_config

STARTUP_SCRIPT_PATH=$dir/startup

MEDIA_SERVER_BACKUP=$dir/media_server
MEDIA_DISK_MOUNTPOINT=/media/Fat_Man
MEDIA_SERVER_MEDIADIR=$MEDIA_DISK_MOUNTPOINT/media
MEDIA_SERVER_USERDIR=~/docker

# Use this for tests and running single commands using the utils library
echoInfo "Gitkraken"
wget_install_deb "Gitkraken" "https://release.gitkraken.com/linux/gitkraken-amd64.deb"