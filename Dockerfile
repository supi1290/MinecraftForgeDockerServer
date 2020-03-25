# Welches Betriebsystem mit FROM
FROM alpine:latest

LABEL description "Minecraft Forge Server"

#set Arguments
ARG FORGE_VERSION=14.23.5.2847
ARG FORGE_URL=https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.12.2-14.23.5.2847/forge-1.12.2-14.23.5.2847-installer.jar
ARG FORGE_INSTALLER=forge-1.12.2-14.23.5.2847-installer.jar
ARG RCON_URL=...

#set workdir
WORKDIR /opt/mcserver

# install Java/Anti-Zip
RUN apk add --force \
\
&&  echo "## Setup permissions ##" \
&&  addgroup -g 9987 mcserver
&&  adduser -u 9987 -Hh /var/mcserver -G mcserver -s /sbin/nologin -D mcserver \
&&  mkdir -p /var/rcon /var/server
\
&&  echo "## Download and install ForgeServer Version: ${FORGE_VERSION} ##" \
&&  wget "${FORGE_URL}" -p /var/server \
&&  echo "## Running installer ##" \
&&  java "${FORGE_INSTALLER}" \
\
&&  echo "## Download and install RCON ##" \
&&  wget "${RCON_URL}" -p /var/rcon \
\
# make EULA/server.properties
&&  cat <<- EOF >/var/server/server.properties
        #Minecraft server properties
        allow-flight=${SERVER_PROPERTY_ALLOW_FLIGHT:false}
        allow-nether=${SERVER_PROPERTY_ALLOW_NETHER:true}
        broadcast-console-to-ops=${SERVER_PROPERTY_BROADCAST_CONSOLE_TO_OPS:true}
        difficulty=${SERVER_PROPERTY_DIFFICULTY:1}
        enable-command-block=${SERVER_PROPERTY_ENABLE_COMMAND_BLOCK:false}
        enable-query=${SERVER_PROPERTY_ENABLE_QUERY:false}
        enable-rcon=${SERVER_PROPERTY_ENABLE_RCON:false}
        enforce-whitelist=${SERVER_PROPERTY_ENFORCE_WHITELIST:false}
        force-gamemode=${SERVER_PROPERTY_FORCE_GAMEMODE:false}
        function-permission-level=${SERVER_PROPERTY_FUNCTION_PERMISSION_LEVEL:2}
        gamemode=${SERVER_PROPERTY_GAMEMODE:0}
        generate-structures=${SERVER_PROPERTY_GENERATE_STRUCTURES:true}
        generator-settings=${SERVER_PROPERTY_GENERATOR_SETTINGS}
        hardcore=${SERVER_PROPERTY_HARDCORE:false}
        level-name=${SERVER_PROPERTY_LEVEL_NAME:world}
        level-seed=${SERVER_PROPERTY_LEVEL_SEED}
        level-type=${SERVER_PROPERTY_LEVEL_TYPE:DEFAULT}
        max-build-height=${SERVER_PROPERTY_MAX_BUILD_HEIGHT:256}
        max-players=${SERVER_PROPERTY_MAX_PLAYERS:20}
        max-tick-time=${SERVER_PROPERTY_MAX_TICK_TIME:60000}
        max-world-size=${SERVER_PROPERTY_MAX_WORLD_SIZE:29999984}
        motd=${SERVER_PROPERTY_MOTD:A Minecraft Server}
        network-compression-threshold=${SERVER_PROPERTY_NETWORK_COMPRESSION_THRESHOLD:256}
        online-mode=${SERVER_PROPERTY_ONLINE_MODE:true}
        op-permission-level=${SERVER_PROPERTY_OP_PERMISSION_LEVEL:4}
        player-idle-timeout=${SERVER_PROPERTY_PLAYER_IDLE_TIMEOUT:0}
        prevent-proxy-connections=${SERVER_PROPERTY_PREVENT_PROXY_CONNECTIONS:false}
        pvp=${SERVER_PROPERTY_PVP:true}
        query.port=${SERVER_PROPERTY_QUERY_PORT:25565}
        rcon.password=${SERVER_PROPERTY_RCON_PASSWORD}
        rcon.port=${SERVER_PROPERTY_RCON_PORT:25575}
        resource-pack=${SERVER_PROPERTY_RESOURCE_PACK}
        resource-pack-sha1=${SERVER_PROPERTY_RESOURCE_PACK_SHA1}
        server-ip=${SERVER_PROPERTY_SERVER_IP}
        server-port=${SERVER_PROPERTY_SERVER_PORT:25565}
        snooper-enabled=${SERVER_PROPERTY_SNOOPER_ENABLED:true}
        spawn-animals=${SERVER_PROPERTY_SPAWN_ANIMALS:true}
        spawn-monsters=${SERVER_PROPERTY_SPAWN_MONSTERS:true}
        spawn-npcs=${SERVER_PROPERTY_SPAWN_NPCS:true}
        spawn-protection=${SERVER_PROPERTY_SPAWN_PROTECTION:16}
        view-distance=${SERVER_PROPERTY_VIEW_DISTANCE:10}
        white-list=${SERVER_PROPERTY_WHITE_LIST:false}
    EOF \
\
&&  cat <<- EOF >/var/server/eula.txt
        #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
        eula=${EULA:false}
    EOF \
\
# remove independencies
&&  rm "${FORGE_INSTALLER}"