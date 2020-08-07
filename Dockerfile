FROM ubuntu:16.04

USER root
ENV USER_HOME=/home/user
ENV PASSWORD=123456 WIDTH=1920 HEIGHT=1080

# install standard packages:
RUN apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y vnc4server git python vim wmctrl curl apt-transport-https libasound2 build-essential wget sudo

# install Visual Studio Code:
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get update \
    && apt-get install -y code \
    && sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1

# Install NodeJs/NPM from source:
# works, but installing from source takes very long:
#RUN wget https://nodejs.org/dist/v10.16.0/node-v10.16.0.tar.gz; \
#    tar -xzvf node-v10.16.0.tar.gz; \
#    cd node-v10.16.0; \
#    ./configure; \
#    make; \
#    make install; \
#    rm ../node-v10.16.0.tar.gz;

# Install group and user 1000, if it does not exist:
RUN getent group | grep ':1000:' || groupadd usergroup -g 1000
RUN useradd -m user -u 1000 -g 1000 -d $USER_HOME || true
# RUN mkdir -p /root/.m2 && chown $MYUSER:$MYGROUP -R /root

# Install NodeJs/NPM via NVM (must go after useradd)
RUN curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | grep -v "sleep 20" | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && LATEST_LTS=$(nvm ls-remote | grep "Latest LTS" | sed 's/^[^v]*\(v[0-9\.]*\)[^0-9].*$/\1/' | tail -1) \
    && nvm install $LATEST_LTS \
    && cp -R $HOME/.nvm $USER_HOME/ \
    && chown 1000:1000 -R $USER_HOME/ \
    && cat ~/.bashrc | grep NVM_DIR >> /etc/bash.bashrc

RUN . "$HOME/.nvm/nvm.sh" \
    && export NG_CLI_ANALYTICS=ci \
    && npm install -g @angular/cli@9.1.7

COPY ./noVNC/ /noVNC/
RUN chmod 777 -R /noVNC

ADD entrypoint_vnc_startup.sh entrypoint_post_vnc_startup.sh /
RUN chmod a+x /entrypoint*.sh

## switch back to default user
USER 1000
WORKDIR $USER_HOME

RUN . "$HOME/.nvm/nvm.sh" \
    && LATEST_LTS=$(nvm ls-remote | grep "Latest LTS" | sed 's/^[^v]*\(v[0-9\.]*\)[^0-9].*$/\1/' | tail -1) \
    && nvm install $LATEST_LTS \
    && nvm use $LATEST_LTS

# installing angular cli as user does not seem to work?
#RUN . "$HOME/.nvm/nvm.sh" \
#    && export NG_CLI_ANALYTICS=ci \
#    && npm install -g @angular/cli@9.1.7


ENTRYPOINT ["/entrypoint_vnc_startup.sh", "/entrypoint_post_vnc_startup.sh"]
