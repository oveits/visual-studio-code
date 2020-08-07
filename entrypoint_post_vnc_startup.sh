#!/usr/bin/env bash

echo "Add Display Menu launcher with save to file"
if [ ! -r $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh ]; then
  cat <<'__EOF' > $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh
#!/bin/sh
#
# start display menu and save the changed resoltion to a file for next bootup
#
  echo "Starting up Display menu"
  # read DBUS Session Address:
  export DBUS_SESSION_BUS_ADDRESS=$(cat /proc/$(pgrep xfce4-session)/environ | grep -z "^DBUS_SESSION_BUS_ADDRESS=" | awk -F 'DBUS_SESSION_BUS_ADDRESS=' '{print $2}')

  # choose resolution per drop-down menu and save chosen resolution to ~/vocloud/apply-last-seen-resolution.sh for next bootup:
  /usr/bin/xfce4-display-settings \
    && echo "CURRENT_DISPLAY=$(xrandr  | egrep '^[^ ]+ connected [^(]' | awk '{print $1}')" > $HOME/.vocloud/apply-last-seen-resolution.sh \
    && echo "CURRENT_RESOLUTION=$(xrandr | egrep '\*' | awk '{print $1}')" >> $HOME/.vocloud/apply-last-seen-resolution.sh \
    && echo 'xrandr --output $CURRENT_DISPLAY --mode $CURRENT_RESOLUTION' >> $HOME/.vocloud/apply-last-seen-resolution.sh
__EOF
  chmod +x $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh
fi

echo "Add Desktop Icons"
for ICON_FULL_PATH in /usr/share/applications/xfce-display-settings.desktop /usr/share/applications/xfce4-terminal.desktop
do
  [ -r $(basename $ICON_FULL_PATH) ] || cp $ICON_FULL_PATH $HOME/Desktop/
done
# Modify xfce-display-settings.desktop
[ -x $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh ] \
  && sed -i "s_\(Exec=\).*\$_\1$HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh_" $HOME/Desktop/xfce-display-settings.desktop \
  || echo "ERROR: could not find file $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh; Continuing with default launcher..."
chmod 777 $HOME/Desktop/*.desktop 2>/dev/null

# TODO: place this inside a function
# add-resolution() {
# ...
# }
# with usage: $0 "width height" ["width2 heigth2" [...]]
#

echo "Add Resolutions"

declare -a addResolutions=(
"1920 1056 60"
"2560 1416 60"
"2560 1440 60"
"3072 1704 60"
"3072 1728 60"
"3840 2136 60"
"3840 2160 60"
)

# TODO: is ~/.xprofile needed afterwards? If not, consider to just run the xrandr commands instead of creating the file and then executing the file
echo '#!/bin/sh' > ~/.xprofile
DISP=$(xrandr | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

# Read the array values with space
for addRes in "${addResolutions[@]}"; do
  RES=$addRes && \
  MODELINE=$(cvt $(echo $RES) | grep -e "Modeline [^(]" | sed -r 's/.*Modeline (.*)/\1/') && \
  MODERES=$(echo $MODELINE | grep -o -P '(?<=").*(?=")') && \
  echo "xrandr --newmode $MODELINE" >> ~/.xprofile
  echo "xrandr --addmode $DISP $MODERES"  >> ~/.xprofile
done

bash ~/.xprofile

if [ -r "$HOME/.vocloud/apply-last-seen-resolution.sh" ]; then
  echo "Apply last seen resolution"
  bash $HOME/.vocloud/apply-last-seen-resolution.sh
else
  $HOME/.vocloud/xfce4-display-settings-menu-and-save-to-file-for-next-bootup.sh
fi


# Read SSH key, if present:
  #  link from id_rsa_bitbucket, if needed:

[ ! -r $HOME/.ssh/id_rsa ] && [ -r $HOME/.ssh/id_rsa_bitbucket ] && ln -s id_rsa_bitbucket $HOME/.ssh/id_rsa
  # start ssh agent

cat $HOME/.bashrc | grep ssh-agent \
|| if [ -r $HOME/.ssh/id_rsa ] && ! $(cat $HOME/.bashrc | grep ssh-agent); then
  echo 'echo "Starting SSH Agent. Please enter key for BitBucket SSH Key:"' >> $HOME/.bashrc
  echo 'eval $(ssh-agent)'                                                  >> $HOME/.bashrc
  echo 'ssh-add ~/.ssh/id_rsa'                                              >> $HOME/.bashrc
fi

# Link .gitconfig. Create it, if not present:
touch /home/centos/.gitconfig
[ -r /headless/.gitconfig ] || ln -s /home/centos/.gitconfig /headless/.gitconfig

# Create Intellij Startup File
echo "Creating Intellij Startup File"
if [ ! -r $HOME/.vocloud/bin/idea_wrapper.sh ]; then
  mkdir -p $HOME/.vocloud/bin
  cat <<'__EOF' > $HOME/.vocloud/bin/idea_wrapper.sh
#!/bin/sh
#
# Start IntelliJ and make sure all projects are closed on next start, if IntelliJ has crashed
#
  echo "Starting up Intellij"
  /opt/${IDEA_HOME}/bin/idea.sh
  if [ "$?" != "0" ]; then
    echo "ERROR: IntelliJ has aborted"
    echo "As a precaution measure, we close all projects on next bootup"
    sed -i '/<RecentProjectMetaInfo/s/opened="true"//g' $HOME/.IdeaIC2019.3/config/options/recentProjects.xml
  fi
__EOF
  chmod +x $HOME/.vocloud/bin/idea_wrapper.sh
fi

echo "Starting up IntelliJ"
mkdir -p $HOME/log \
  && $HOME/.vocloud/bin/idea_wrapper.sh \
     | tee -a ${HOME}/log/idea.log


exec $@

