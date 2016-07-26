#!/bin/bash

# xu-autohibernate.sh (0.2)
# xubuntu (15/16) auto-hibernate script
# License GPLv3+: GNU GPL version 3 or later: http://gnu.org/licenses/gpl.html
# No warranty. Software provided as is.
# Copyright Matthew Wilson, 2015-16.
# https://github.com/mxwilson


# CHANGE THESE TWO VARIABLES BELOW

# define the local user
my_username="username"

# minutes of inactivity until hibernation (used to control xautolock)
sleepytime=55 

# must run as root

if [ "$USER" != "root" ]
	then
	echo "Must be run as root. Bye."
	exit
fi

echo "Starting hibernate script for Xubuntu"
echo "Local user: $my_username"

read -p "Continue? (y/n)" somevar

case "$somevar" in
        y|Y )
                ;;
        * )
                echo "Bye"; exit;;
esac

unset somevar

# install the programs i need

echo "Installing gnome-screensaver-command, xautolock"

read -p "Continue? (y/n)" somevar

case "$somevar" in
        y|Y )
                ;;
        * )
                echo "Bye"; exit;;
esac

unset somevar

if [ ! -e "/usr/bin/gnome-screensaver-command" ]
	then
	apt-get install -y gnome-screensaver
fi


if [ ! -e "/usr/bin/xautolock" ]
	then
	apt-get install -y xautolock
fi

# now install some scripts i need

echo "Installing xautolock hibernate script @ /home/$my_username/xautolock.sh"

cat <<EOF > /home/$my_username/xautolock.sh 
#!/bin/bash
gnome-screensaver-command -l;
sleep 20;
sudo pm-hibernate;
EOF

chown $my_username:$my_username /home/$my_username/xautolock.sh
chmod +x /home/$my_username/xautolock.sh

echo "Now installing xautolock in XFCE session and startup"

if [ ! -d "/home/$my_username/.config/autostart" ]
	then
	mkdir /home/$my_username/.config/autostart
fi

cat <<EOF > /home/$my_username/.config/autostart/xautolock.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=xautolock
Type=Application
Exec=xautolock -time $sleepytime -locker /home/$my_username/xautolock.sh
Terminal=false
StartupNotify=false
Hidden=false
EOF

chown -R $my_username:$my_username /home/$my_username/.config

# also must do visudo 

echo "WILL NOW ECHO $my_username ALL=NOPASSWD:/usr/sbin/pm-hibernate TO /etc/sudoers"

echo "$my_username ALL=NOPASSWD:/usr/sbin/pm-hibernate" >> /etc/sudoers

# now set up wifi recovery and unload modules

echo "Now installing network wakeup recovery to restart network-manager.service"

cat <<EOF > /etc/pm/sleep.d/10_restart_network_manager
#!/bin/sh
case \$1 in
resume|thaw)
sudo /bin/systemctl restart network-manager.service
;;
esac
EOF

chmod +x /etc/pm/sleep.d/10_restart_network_manager

# unload modules

# get name of wifi driver

kk=$(lshw | grep wireless | grep driver | cut -f3  -d '=' | awk '{print $1}')

if [ -z "$kk" ]; then
	echo "No wireless card found. Will not install unload_modules."
	echo "Done!"; exit;
else
	echo "Install optional /etc/pm/config.d/unload_modules with wifi driver: $kk?"
	read -p "Continue? (y/n)" somevar

	case "$somevar" in
        	y|Y )
                	;;
        	* )
        		echo "Done! Unload_modules not installed."; exit;;
	esac

cat <<EOF > /etc/pm/config.d/unload_modules
SUSPEND_MODULES="\$SUSPEND_MODULES $kk"
EOF

fi

echo "Done!"
exit
