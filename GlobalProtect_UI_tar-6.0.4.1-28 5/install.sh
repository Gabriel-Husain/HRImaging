#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "root privilege is required..."
  exit 1
fi

# manually install gp linux client
UPGRADE=0
GPA_MODE_UPGRADE=0
GPDIR=/opt/paloaltonetworks/globalprotect
LOG=$GPDIR/install.log
mkdir -m 755 -p $GPDIR && touch $LOG && chmod 644 $LOG

# write header
exec 2>>$LOG
echo ' '>>$LOG
echo '==============================='>>$LOG
echo ' install.sh'>>$LOG
echo '==============================='>>$LOG
date >> $LOG

# check ubuntu
RUNNING_IN_UBUNTU="$(cat /etc/os-release | grep ID=ubuntu)"
if [ "$RUNNING_IN_UBUNTU" ]; then
  echo "Running in Ubuntu." | tee -a $LOG
fi

# check systemd
USE_SYSTEMD="$(pidof systemd)"
if [ "$USE_SYSTEMD" ]; then
  echo "systemd is detected." | tee -a $LOG
else
  echo "systemd is not detected, init will be used." | tee -a $LOG
fi
################################################## stop everything first ##################################################
# Stop gp service when i's running
if [ "$(pidof PanGPS)" ]; then
  echo "gp service is running and we need to stop it..." | tee -a $LOG
  if [ "$USE_SYSTEMD" ]; then
    systemctl stop gpd
  else
    service gpd stop
  fi
  sleep 5
fi

#stop gpa
if [ "$(pidof PanGPA)" ]; then
  echo "Stopping gpa..." | tee -a $LOG
  if [ "$RUNNING_IN_UBUNTU" ]; then
    if [ -e /etc/profile.d/PanMSInit.sh ]; then
      kill -9 `pidof PanGPA`
      rm -f /etc/profile.d/PanMSInit.sh
      GPA_MODE_UPGRADE="1"
    else
      if [ "$USE_SYSTEMD" ]; then
        su -c 'XDG_RUNTIME_DIR="/run/user/$UID" DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus" systemctl --user stop gpa' $SUDO_USER
      fi
    fi
  else
    kill -9 `pidof PanGPA`
  fi
fi

#stop gp-cli
if [ "$(pidof globalprotect)" ]; then
  echo "Stopping globalprotect..." | tee -a $LOG
  kill -9 `pidof globalprotect`
fi

#stop gpui
if [ "$(pidof PanGPUI)" ]; then
  echo "Stopping gpui..." | tee -a $LOG
  kill -9 `pidof PanGPUI`
fi

if [ -f $GPDIR/PanGPS ]; then
  echo "This is upgrading..." | tee -a $LOG
  UPGRADE="1"
fi

# Remove old symbol link
if [ -e /usr/local/bin/globalprotect ]; then
  rm -f /usr/local/bin/globalprotect
fi

# Copy files
if [ -d release ]; then
    cp -f release/* $GPDIR/
else
    cp -f globalprotect PanGPA PanGPS PanGpHip PanGpHipMp $GPDIR/
    cp -f globalprotect.sha256 PanGPA.sha256 PanGPS.sha256 $GPDIR/
    if [ -f PanGPUI ]; then
        cp -f PanGPUI $GPDIR/
    fi
fi

cp -df *.so* $GPDIR/
cp -f license.cfg $GPDIR/
cp -f gpd gpd.service gpa.service $GPDIR/
cp -f PanMSInit.sh pre_exec_gps.sh gpshow.sh gp_support.sh uninstall.sh  $GPDIR/
cp -f gpui_apt_dep.sh gpui_yum_dep.sh $GPDIR/
cp -f globalprotect.1.gz /usr/share/man/man1
if [ -f PanGPUI.desktop ]; then
    cp -f PanGPUI.desktop $GPDIR/
fi

if [ -f gp.desktop ]; then
    cp -f gp.desktop $GPDIR/
fi

if [ -f globalprotect.desktop ]; then
    mkdir -m 755 -p /usr/share/applications
    cp -f globalprotect.desktop /usr/share/applications
fi

if [ -f globalprotect.png ]; then
    mkdir -m 755 -p /usr/share/icons/hicolor/48x48/apps
    cp -f globalprotect.png /usr/share/icons/hicolor/48x48/apps
fi

# When first time installation, install both gps and gpa as service
if [ $UPGRADE == 0 ]; then
  echo "Enable gps service..." | tee -a $LOG
  if [ "$USE_SYSTEMD" ]; then
    cp $GPDIR/gpd.service /lib/systemd/system/gpd.service
    chmod +x $GPDIR/pre_exec_gps.sh
    systemctl enable gpd.service >> $LOG
  else
    cp $GPDIR/gpd /etc/init.d/gpd
    chmod 755 /etc/init.d/gpd
    update-rc.d gpd defaults >> $LOG
    update-rc.d gpd enable >> $LOG
  fi

  echo "Enable gpa service..." | tee -a $LOG
  if [ "$RUNNING_IN_UBUNTU" ]; then
    cp $GPDIR/gpa.service /etc/systemd/user/gpa.service
    systemctl --global enable gpa.service >> $LOG
  else
    cp $GPDIR/PanMSInit.sh /etc/profile.d/
  fi
  sleep 1
else
  if [ $GPA_MODE_UPGRADE == 1 ]; then
    echo "Enable gpa service..." | tee -a $LOG
    cp $GPDIR/gpa.service /etc/systemd/user/gpa.service
    systemctl --global enable gpa.service >> $LOG
  fi
fi

# Ensure symbol link for GPI
if [ ! -e /usr/bin/globalprotect ] && [ ! -h /usr/bin/globalprotect ]; then
  echo "Create symlink for gp cli..." | tee -a $LOG
  sudo ln -s $GPDIR/globalprotect /usr/bin/globalprotect >> $LOG
fi

# Start service after install or upgrade
echo "Starting gp service..." | tee -a $LOG
if [ "$USE_SYSTEMD" ]; then
  systemctl start gpd
else
  sleep 3
  service gpd start
fi
sleep 3

# GP autostart
if [ -f $GPDIR/PanGPUI.desktop ]; then
    echo "Enable gp autostart..." | tee -a $LOG
    cp $GPDIR/PanGPUI.desktop /etc/xdg/autostart/
fi

if [ -f $GPDIR/gp.desktop ]; then
    cp $GPDIR/gp.desktop /usr/share/applications/gp.desktop 2>> $LOG
    echo "Set default browser ..." | tee -a $LOG
    update-desktop-database 2>>$LOG
fi

# Start GPA for login user
LOGIN_USER="$(logname)"
EFFECT_USER="$(whoami)"
echo "Starting gpa..." | tee -a $LOG
echo "Login User: $LOGIN_USER" >> $LOG
echo "SUDO User: $SUDO_USER" >> $LOG
echo "Effect User: $EFFECT_USER" >> $LOG

if [ "$RUNNING_IN_UBUNTU" ]; then
  if [ -n "$SUDO_USER" ]; then
    echo "start GPA for $SUDO_USER" >> $LOG
    su -c 'XDG_RUNTIME_DIR="/run/user/$UID" DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus" systemctl --user start gpa' $SUDO_USER
  elif [ -n "$LOGIN_USER" ] && [ "$LOGIN_USER" == "$EFFECT_USER" ]; then # login user is root
    echo "start GPA for $EFFECT_USER" >> $LOG
    systemctl --user start gpa >> $LOG
  elif [ -n "$LOGIN_USER" ] && [ "$LOGIN_USER" != "$EFFECT_USER" ]; then # su
    echo "start GPA for $LOGIN_USER" >> $LOG
    su -c 'XDG_RUNTIME_DIR="/run/user/$UID" DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus" systemctl --user start gpa' $LOGIN_USER
    echo -e "\033[1;33mWarning:\033[0m Please switch back to user $LOGIN_USER before you run globalprotect." | tee -a $LOG
  fi
else
  if [ -n "$SUDO_USER" ]; then
    echo "start GPA for $SUDO_USER" >> $LOG
    su -c "$GPDIR/PanGPA start &" $SUDO_USER
  elif [ -n "$LOGIN_USER" ] && [ "$LOGIN_USER" == "$EFFECT_USER" ]; then # login user is root
    echo "start GPA for $EFFECT_USER" >> $LOG
    $GPDIR/PanGPA start & >> $LOG
  elif [ -n "$LOGIN_USER" ] && [ "$LOGIN_USER" != "$EFFECT_USER" ]; then # su
    echo "start GPA for $LOGIN_USER" >> $LOG
    su -c "$GPDIR/PanGPA start &" $LOGIN_USER
    echo -e "\033[1;33mWarning:\033[0m Please switch back to user $LOGIN_USER before you run globalprotect." | tee -a $LOG
  fi
fi


# Start PanGPUI if installed and if login user
if [ -f $GPDIR/PanGPUI ] && [ -n "$LOGIN_USER" ]; then
    # Install PanGPUI Dependencies
    echo "Check for and install PanGPUI dependencies..." | tee -a $LOG
    LINUX_DISTRO=$(cat /etc/*-release)
    if [[ $LINUX_DISTRO == *Ubuntu* ]]; then
        $GPDIR/gpui_apt_dep.sh
    else
        $GPDIR/gpui_yum_dep.sh
    fi

    sleep 1s # Give PanGPA chance to initialize listen socket
    echo "Starting gpui for $LOGIN_USER..." | tee -a $LOG
    su -c "$GPDIR/PanGPUI start &" $LOGIN_USER
fi
