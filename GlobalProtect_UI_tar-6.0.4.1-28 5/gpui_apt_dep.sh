#!/bin/bash

# apt-get installs
echo "apt-get: Installing Qt dependencies..."
apt-get install -y libqt5webkit5 > /dev/null
echo "apt-get Installing wmctrl..."
apt-get install -y wmctrl  > /dev/null 2>&1