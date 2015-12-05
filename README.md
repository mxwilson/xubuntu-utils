# Xubuntu (15.10) auto-hibernate script

## xu-autohibernate.sh (0.1)

## Synopsis

This script allows for the automatic hibernation of Xubuntu 15.10 using XFCE after a pre-defined amount of time. This solves many of the issues related to this procedure including restoring the network connection after wakeup and locking the screen.

This script must be run with super-user priviledges. 3 Variables may be changed to customize the script: my_username, sleepytime (length of time in minutes before hibernate) and wifi_driver (name of wifi driver – can be found by running $lshw | grep wireless | grep driver). To run: $chmod +x xu-autohibernate.sh; /xu-autohibernate.sh

First the script installs gnome-screensaver and xautolock. Xautolock will be inserted into the session and startup options in XFCE and will call a locking and hibernation script at /home/username/xautolock.sh after the number of minutes you have chosen. This script calls gnome-screensaver-command -l (locking the screen) and sudo pm-hibernate. Visudo is also updated to allow your local user to run this command. 

Another script will be installed at /etc/pm/sleep.d/10_restart_network_manager that re-starts the network-manager.service. This solves the issue of networking being completely disabled upon thawing the machine. This issue seems to be new in Xubuntu 15.10. Prior to this release, adding a $suspend_modules command to /etc/pm/config.d/unload_modules was the solution to this issue. This is an optional portion of the script, and is the only part requiring a wifi driver name (Using both is working for me).

## License

Copyright 2015, Matthew Wilson.
License GPLv3+: GNU GPL version 3 or later http://gnu.org/licenses/gpl.html.
No warranty. Software provided as is.
