FROM alpine:latest

LABEL description "Minecraft Forge Server"

# this fork is maintained by supi1290
MAINTAINER Haider Sebastian <haider.sebastian.michael@gmail.com>

WORKDIR /opt/mcserver/server

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        gcc@main \
        git@main \
        libc-dev@main \
        libstdc++@main \
        openjdk8-jre@community \
        tini@community \
        unzip@main \
    \
    && echo "## Setup permissions ##" \
    && addgroup -g 9987 minecraft \
    && adduser -u 9987 -Hh /var/minecraft -G minecraft -s /sbin/nologin -D minecraft \
    \
    && echo "## Download and install RCON ##" \
    && mkdir -p /opt/mcserver/build/mcrcon \
    && cd /opt/mcserver/build/mcrcon \
    && git clone git://git.code.sf.net/p/mcrcon/code \
    && cd code \
    && gcc mcrcon.c -o mcrcon \
    && mv mcrcon /usr/local/bin/ \
    \
    && rm -rf redist doc serverquerydocs tsdns CHANGELOG \
    && ldconfig /usr/local/lib \
    && chown -R minecraft.minecraft /opt/mcserver\
    \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/* \
    \
    && echo "set a very secure root password and enable su" \
    && echo "root:ciscocisco" | chpasswd \
    && chmod u+s /bin/su

# 9987 default voice, 10011 server query, 30033 file transport,
# 49152-65535 alternative ports
EXPOSE "25565/tcp" "25575/tcp"

# setup directory where minecraft data is stored
VOLUME /opt/mcserver

# deploy init script
COPY docker-entrypoint.sh /usr/local/bin/

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]

# change to none root user
USER minecraft

# additional post-installation configurations
CMD ["/opt/mcserver/server/RUN.sh"]