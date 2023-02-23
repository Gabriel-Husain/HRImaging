#!/bin/bash

# Determine Linux Distro and Version
. /etc/os-release

linux_ver=${VERSION_ID:0:1}
echo "Linux Version: $ID $linux_ver"

# Install Top Icons Shell Extension
sudo yum -y install gnome-shell-extension-top-icons

# Install Tweak Tool
if [ "$linux_ver" = "7" ]; then
    sudo yum -y install gnome-tweak-tool
elif [ "$linux_ver" = "8" ]; then
    sudo yum -y install gnome-tweaks
else
    echo "Error: Unsupported Linux version: $linux_ver"
fi
