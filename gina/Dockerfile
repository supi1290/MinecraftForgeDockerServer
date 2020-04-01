FROM alpine:latest

LABEL description "Minecraft Forge Server"

MAINTAINER Haider Sebastian <haider.sebastian.michael@gmail.com>

WORKDIR /opt/mcserver

RUN apk add --force \
    bash@main \
    git@main \
    openjdk8-jre@community \
    libstdc++@main \
    tini@community \
    gcc@main \
    libc-dev@main \
    unzip@main \
\
&&  echo "## Setup permissions ##" \
&&  addgroup --gid 9987 minecraft \
&&  adduser -u 9987 -Hh /opt/mcserver -G minecraft -s /sbin/nologin -D minecraft \
\
&&  echo "## Download and install RCON ##" \
&&  mkdir -p /opt/mcserver/build/mcrcon \
&&  cd /opt/mcserver/build/mcrcon \
&&  git clone git://git.code.sf.net/p/mcrcon/code \
&&  cd code \
&&  gcc mcrcon.c -o mcrcon \
&&  mv mcrcon /usr/local/bin/ \
\
&&  chown -R :9987 /opt/mcserver \
&&  chmod 775 /opt/mcserver \
&&  chmod g+s /opt/mcserver \
\
&& echo "set a very secure root password and enable su" \
&& echo "root:ciscocisco" | chpasswd \
&& chmod u+s /bin/su

VOLUME /opt/mcserver

COPY docker-entrypoint.sh /opt/mcserver

ENTRYPOINT ["/sbin/tini", "--", "./docker-entrypoint.sh"]

USER minecraft

CMD ["/opt/mcserver/server/RUN.sh"]