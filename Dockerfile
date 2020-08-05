FROM ubuntu:16.04
RUN apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y vnc4server git python vim wmctrl curl apt-transport-https libasound2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg; \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/; \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'; \
    apt-get update; \
    apt-get install -y code; \
    sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1
ENV PASSWORD=123456 WIDTH=1920 HEIGHT=1080
COPY ./noVNC/ /noVNC/
COPY ./startup.sh /startup.sh
RUN chmod 777 /startup.sh; \
    chmod 777 -R /noVNC

RUN npm install -g @angular/cli@9.1.7

RUN groupadd usergroup -g 1000 \
    && useradd -m user-u 1000 -g 1000 -d /home/user
# RUN mkdir -p /root/.m2 && chown $MYUSER:$MYGROUP -R /root

ENTRYPOINT ["/startup.sh"]