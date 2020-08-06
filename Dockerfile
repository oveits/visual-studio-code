FROM ubuntu:16.04
RUN apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y vnc4server git python vim wmctrl curl apt-transport-https libasound2 build-essential wget sudo
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg; \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/; \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'; \
    apt-get update; \
    apt-get install -y code; \
    sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1
ENV PASSWORD=123456 WIDTH=1920 HEIGHT=1080

# Install NodeJs/NPM:

# works, but installing from source takes very long:
#RUN wget https://nodejs.org/dist/v10.16.0/node-v10.16.0.tar.gz; \
#    tar -xzvf node-v10.16.0.tar.gz; \
#    cd node-v10.16.0; \
#    ./configure; \
#    make; \
#    make install; \
#    rm ../node-v10.16.0.tar.gz;

# does not work:
#RUN curl -sL https://rpm.nodesource.com/setup | bash -
#    RUN yum install –y nodejs \
#    RUN node –version
RUN groupadd usergroup -g 1000 \
    && useradd -m user -u 1000 -g 1000 -d /home/user
# RUN mkdir -p /root/.m2 && chown $MYUSER:$MYGROUP -R /root

RUN curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | grep -v "sleep 20" | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && LATEST_LTS=$(nvm ls-remote | grep "Latest LTS" | sed 's/^[^v]*\(v[0-9\.]*\)[^0-9].*$/\1/' | tail -1) \
    && nvm install $LATEST_LTS \
    && cp -R $HOME/.nvm /home/user/ \
    && chown user:usergroup -R /home/user/ \
    && cat ~/.bashrc | grep NVM_DIR >> /etc/bash.bashrc

RUN . "$HOME/.nvm/nvm.sh" \
    && export NG_CLI_ANALYTICS=ci \
    && npm install -g @angular/cli@9.1.7

COPY ./noVNC/ /noVNC/
COPY ./startup.sh /startup.sh
RUN chmod 777 /startup.sh; \
    chmod 777 -R /noVNC
USER user
WORKDIR /home/user


RUN . "$HOME/.nvm/nvm.sh" \
    && LATEST_LTS=$(nvm ls-remote | grep "Latest LTS" | sed 's/^[^v]*\(v[0-9\.]*\)[^0-9].*$/\1/' | tail -1) \
    && nvm use $LATEST_LTS

ENTRYPOINT ["/startup.sh"]
