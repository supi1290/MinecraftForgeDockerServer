FROM alpine:latest

LABEL description "Minecraft Forge Server"

ARG JAVA_URL=https://javadl.oracle.com/webapps/download/AutoDL?xd_co_f=NTA1Y2E2MTYtMGIyZi00YzBlLWI1ODktOTBmOTBjOGJkYTY1&BundleId=241524_1f5b5a70bf22433b84d0e960903adac8
ARG JAVA_FILE_NAME=jre-8u241-linux-i586.tar.gz

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
&&  addgroup -g 9987 minecraft \
&&  adduser -u 9987 -Hh /opt/mcserver -G minecraft -s /sbin/nologin -D minecraft \
&&  mkdir -p /opt/mcserver/build/mcrcon \
\
&&  echo "## Download and install RCON ##" \
&&  cd /opt/mcserver/build/mcrcon \
&&  git clone git://git.code.sf.net/p/mcrcon/code \
&&  cd code \
&&  gcc mcrcon.c -o mcrcon \
&&  mv mcrcon /usr/local/bin/

VOLUME /opt/mcserver

COPY docker-entrypoint.sh /opt/mcserver

ENTRYPOINT ["/sbin/tini", "--", "./docker-entrypoint.sh"]