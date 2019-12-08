#!/bin/sh
printf "$PASSWORD\n$PASSWORD\n\n" | vncpasswd;
vncserver :1;
vncserver -kill :1;
echo "code --user-data-dir /; wmctrl -i -r 0x800001 -e 0,0,0,$WIDTH,$HEIGHT" >> ~/.vnc/xstartup;
vncserver -localhost -depth 24 -geometry $WIDTH'x'$HEIGHT :1;
/noVNC/utils/launch.sh --vnc localhost:5901;
