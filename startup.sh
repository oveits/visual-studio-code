#!/bin/sh

VNC_ARGS=${VNC_ARGS:="-depth 24 -geometry ${WIDTH}x${HEIGHT} :1"}

# set REMOTE_VNC to true, if direct VNC access from the Internet is allowed:
REMOTE_VNC=${REMOTE_VNC:=true}
[ "$REMOTE_VNC" != "true" ] && echo "$VNC_ARGS" | grep -q -v localhost && VNC_ARGS="-localhost $VNC_ARGS"

# set VNC password:
printf "$PASSWORD\n$PASSWORD\n\n" | vncpasswd;

## Configure VNC Server via configuration file (~/.vnc/xstartup)
# create default xstartup file by starting and killing a vncserver:
vncserver :1
  vncserver -kill :1
  # add a line that visual studio code is started, if it is not already present:
  cat ~/.vnc/xstartup | egrep '^code' || echo "code --verbose; sleep 1; wmctrl -i -r 0x800001 -e 0,0,0,${WIDTH},${HEIGHT}" >> ~/.vnc/xstartup;

# Start VNC Server:
vncserver $VNC_ARGS

# Start noVNC Server:
/noVNC/utils/launch.sh --vnc localhost:5901;
