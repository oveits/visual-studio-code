#!/bin/sh

VNC_ARGS=${VNC_ARGS:="-depth 24 -geometry ${WIDTH}x${HEIGHT} :1"}

# set REMOTE_VNC to true, if direct VNC access from the Internet is allowed:
REMOTE_VNC=${REMOTE_VNC:=true}
[ "$REMOTE_VNC" != "true" ] && echo "$VNC_ARGS" | grep -q -v localhost && VNC_ARGS="-localhost $VNC_ARGS"

# set VNC password:
printf "$PASSWORD\n$PASSWORD\n\n" | vncpasswd

## Configure VNC Server via configuration file ($HOME/.vnc/xstartup)
# create default xstartup file by starting and killing a vncserver:
  rm $HOME/.vnc/xstartup || true
  vncserver :1
  vncserver -kill :1
  # replace the (or add a) line to start visual studio code with the latest parameters:
  cat $HOME/.vnc/xstartup | egrep -v '^code' > $HOME/.vnc/xstartup.new

  cat <<'EOF' >> $HOME/.vnc/xstartup.new
if test "$(id -u)" = "0"; then
  # as root:
  code --user-data-dir /root
else
  # as a normal user:
  code
fi

# find window ID:
VSCODE_WINDOW_ID=$(xwininfo -tree -root | grep "Visual Studio Code" | head -1 | awk '{print $1}') 
echo VSCODE_WINDOW_ID=$VSCODE_WINDOW_ID
EOF

  echo '# resize Visual Studio Code Window:' >> $HOME/.vnc/xstartup.new
  echo "wmctrl -i -r \${VSCODE_WINDOW_ID} -e 0,0,0,${WIDTH},${HEIGHT}" >> $HOME/.vnc/xstartup.new
  cp $HOME/.vnc/xstartup.new $HOME/.vnc/xstartup

# Start VNC Server:
vncserver $VNC_ARGS

# Start noVNC Server:
/noVNC/utils/launch.sh --vnc localhost:5901

