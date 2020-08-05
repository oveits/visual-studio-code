# TODO
* [ ] to Dockerfile: remove version from idea foldername (pros and cons to be discussed)
      `ln -s ${IDEA_HOME} /headless/idea-IC`
* [x] Find out how to place a desktop item to the desktop for intellij
* [x] Start intellij on bootup of the container
* [ ] Make git@bitbucket.org:vocon-IT/intellij-desktop.git open source, so it can be used by our customers. In the moment, other cannot deploy the IntelliJ Desktop as described in the first chapter below
* [x] Improve the IntelliJ bash prompt to show the foldername and the git branch
* [x] Add .ssh to the list of mapped volumes
* [x] Add ssh-agent to .bashrc
* [x] Link /home/centos/.gitconfig to /headless/.gitconfig
* [ ] allow docker and kubectl commands from inside the container (by mapping volumes to executables and .kube and .docker? )
* [x] save last used resolution and use as default for next bootup (read with xrandr and save to /home/centos/.vocloud?)
* [ ] for development, create and use docker images with tags derived from the branch name (e.g. vocon/intellij-desktop:caas-53-whatever-branchname )
* [x] Adjust and test noVNC resolutions to minus 24 pixel height
  * [x] FHD
  * [x] UHD (150%)
  * [x] UHD (125%)
  * [x] UHD (100%)
* [x] Bug: if display is changed via Display Icon, then the .vocloud/.resolution.sh file is not updated, leading to a false resolution after next container reboot. To fix this, redefine the Display Desktop icon.
* [ ] Bug: if display is changed via Application -> ... -> Display or context menu -> ... -> Display , then the .vocloud/.resolution.sh file is not updated, leading to a false resolution after next container reboot. To fix this, redefine the Display Desktop icon.
* [ ] Bug: IntelliJ crashes, upon opening project [oveits/docker-headless-vnc-container](https://github.com/oveits/docker-headless-vnc-container) 
  * [x] Workaround: After an IntelliJ crash, make sure that IntelliJ starts without any project opened next time
* [ ] Add IntelliJ Icon on the Desktop
* [ ] Make sure IntelliJ Desktop opens a browser when clicking on a link
* [ ] Visual Studio Code
  * [x] standalone Deployment
  * [x] VNC
  * [x] noVNC
  * [ ] non-root user
  * [ ] persistence
  * [ ] integrated into IntelliJ Desktop

  
# Deploy IntelliJ Desktop on Kubernetes

```
[ -d intellij-desktop ] && git clone git@bitbucket.org:vocon-IT/intellij-desktop.git
bash intellij-desktop/deploy.sh
```

# Access IntelliJ Desktop

## Access IntelliJ Desktop via VNC Viewer (preferred; allow cut&paste from your own PC)

Create a connection in the VNC viewer with following data:
```
Host: <ip-of-your-kubernetes-host>
Port: 5901
Password: vncpassword
```
and connect to the machine.

## Access IntelliJ Desktop via Browser

Open a browser and head to following URL (change password in the URL, if you have not used a default password in the deployment file above.

```
http://<ip-of-your-kubernetes-host>:6901/?password=vncpassword/
```

# Adapt Resolution

--> right-click on Desktop
--> Applications
--> Settings
--> Display
--> choose resolution from drop-down
--> Apply
--> Close

# Start IntelliJ

--> right click on Desktop --> Open Terminal here
```
[ -r /headless/idea-IC ] || ln -s ${IDEA_HOME} /headless/idea-IC
bash /headless/idea-IC/bin/idea.sh &
```

# Delete IntelliJ Desktop

```
kubectl delete deploy intellij-desktop
```

# Developer Hints

## Restart the intellij POD after changing some code

Run in the local GIT repo `intellij-desktop`:
```
IMAGE=$(cat deploy/intellijDesktopDeployment.yaml | egrep "^[ ]*image:" | awk '{print $2}') \
  && sudo docker build -t ${IMAGE} . \
  && sudo docker push ${IMAGE} \
  && OLD_POD=$(kubectl get pod | awk '{print $1}' | grep intellij) \
  && bash deploy.sh \
  && kubectl delete POD $OLD_POD \
  && watch kubectl get pod
```
You can stop watching the outcome of the get pod command by pressing Ctrl-C.

## Start an exec session into the intellij container

Note: you need to wait for the POD to be up and running

```
kubectl exec -it $(kubectl get pod | grep Running | grep intellij-desktop | awk '{print $1}') bash
```

# Usage

## Features

### Keyboard Layout

	For changing the keyboard layout used on the machine, just change your own keyboard mapping by pressing Windows Key + Space.

## Cloning the project

[Clone a repository](https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html)

Setting up an SSH Key on Bitbucket for authentication:
[Set up a SSH Key](https://confluence.atlassian.com/bitbucket/set-up-an-ssh-key-728138079.html#SetupanSSHkey-ssh2).

## Starting the container

Docker command for running the latest container version with port mapping ('5091' - VNC and '6091' - HTML), volume mapping for persisting Intellij settings and Projects created inside the vocon folder.

	docker run -it --rm -p 5901:5901 -p 6901:6901 \
		-v ~/intellij/.Idea.share:/headless/.local/share/JetBrains \
		-v ~/intellij/.Idea.java:/headless/.java \
		-v ~/intellij/.Idea.maven:/headless/.m2 \
		-v ~/intellij/.Idea:/headless/.IdeaIC2019.3 \
		-v ~/vocon:/headless/vocon \
	gabrielnarodrigues/intellij-desktop:latest bash

# Resolutions

## Starting the container with a custom resolution

You can use the docker run command specifying the environmnent variable VNC_RESOLUTION.

    docker run -e VNC_RESOLUTION=3840x2120 gabrielnarodrigues/intellij-desktop:latest

## Adding more custom resolutions

Inside the 'resolution.sh' file, look for the declaration of the String Array and add the wanted resolution. After the changes, the image needs to be rebuilt and the container started with the new version.

    declare -a StringArray=("3840 2120 60" "2000 1120 60")

## Retrieving resolution from the browser via Javascript

For retrieving user information about the used resolution of his PC, you can use the following commands:

    screen.width + "x" + screen.height
    window.screen.width * window.devicePixelRatio + "x" + window.screen.height * window.devicePixelRatio

## Recommended resolutions

For correct sizing when using the no-VNC version (browser), it's recommended to extract 40 pixels of the length of the resolution for better fitting inside the browser window. i.e.:

    4k: 3840x2120
    FHD: 1920x1040
