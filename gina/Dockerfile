FROM alpine:latest

LABEL description "Minecraft Forge Server"

# this fork is maintained by supi1290
MAINTAINER Haider Sebastian <haider.sebastian.michael@gmail.com>

# change here to desired version
ARG TEAMSPEAK_CHECKSUM=6f414b427f43aef5a0ab95e0b996b7ba9620ad7b0017fff8c9bdb2855beef066
ARG TEAMSPEAK_URL=https://files.teamspeak-services.com/releases/server/3.12.0/teamspeak3-server_linux_alpine-3.12.0.tar.bz2

WORKDIR /opt/ts3server

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
        ca-certificates@main \
        tini@community \
        unzip@main \
    \
    && echo "## Setup permissions ##" \
    && addgroup -g 9987 ts3server \
    && adduser -u 9987 -Hh /var/ts3server -G ts3server -s /sbin/nologin -D ts3server \
    && mkdir -p /var/ts3server /var/run/ts3server \
    \
    && echo "## Download and install RCON ##" \
    && mkdir -p /opt/ts3server/build/mcrcon \
    && cd /opt/ts3server/build/mcrcon \
    && git clone git://git.code.sf.net/p/mcrcon/code \
    && cd code \
    && gcc mcrcon.c -o mcrcon \
    && mv mcrcon /usr/local/bin/ \
    \
    && mv /opt/ts3server/*.so /opt/ts3server/redist/* /usr/local/lib \
    && rm -rf redist doc serverquerydocs tsdns CHANGELOG \
    && ldconfig /usr/local/lib \
    && chown -R ts3server.ts3server /opt/ts3server /var/ts3server /var/run/ts3server\
    \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/* \
    \
    && echo "set a very secure root password and enable su" \
    && echo "root:ciscocisco" | chpasswd \
    && chmod u+s /bin/su

# 9987 default voice, 10011 server query, 30033 file transport,
# 49152-65535 alternative ports
EXPOSE "9987/udp" "10011/tcp" "30033/tcp"

# setup directory where user data is stored
# /opt/ts3server/ files
# /var/ts3server/ logs
# /var/run/ts3server/ config
VOLUME /opt/ts3server/ /var/ts3server/ /var/run/ts3server/

# deploy init script
COPY docker-entrypoint.sh /opt/ts3server

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "./docker-entrypoint.sh"]

# change to none root user
USER ts3server

# additional post-installation configurations
CMD ["./ts3server", "inifile=/var/run/ts3server/ts3server.ini"]