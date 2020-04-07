#!/usr/bin/env bash

# terminate on errors
set -xe

# define as docker compose var or default ""
MC_GINA_GIT_REPO=${MC_GINA_GIT_REPO:-""}
MC_GINA_GIT_USER=${MC_GINA_GIT_USER:-""}
MC_GINA_GIT_PASSWD=${MC_GINA_GIT_PASSWD:-""}
MC_GINA_INTERVAL=${MC_GINA_INTERVAL:-""}

# Download and unzip server.zip if no server datei was found
echo "## Download Server Repo ##"
#cd /opt/mcserver
#git clone ${MC_GINA_GIT_REPO}
FILE=/opt/mcserver/server/eula.txt
if [[ ! -f "$FILE" ]]; then
    echo "ciscocisco" | su -c "wget -qO- https://codeload.github.com/ts3partyMinecraft/SupisAdventureModpackServerBackup/zip/master \
        | unzip -d /opt/mcserver/server master"
fi

chown -R minecraft.minecraft /opt/mcserver/server

# check if server.properties file exists, when not make it
FILE=/opt/mcserver/server/server.properties
if [[ ! -f "$FILE" ]]; then
    cat <<- EOF >/opt/mcserver/server/server.properties
        #Minecraft server properties
        allow-flight=${SERVER_PROPERTY_ALLOW_FLIGHT:-false}
        allow-nether=${SERVER_PROPERTY_ALLOW_NETHER:-true}
        broadcast-console-to-ops=${SERVER_PROPERTY_BROADCAST_CONSOLE_TO_OPS:-true}
        difficulty=${SERVER_PROPERTY_DIFFICULTY:-1}
        enable-command-block=${SERVER_PROPERTY_ENABLE_COMMAND_BLOCK:-false}
        enable-query=${SERVER_PROPERTY_ENABLE_QUERY:-false}
        enable-rcon=${SERVER_PROPERTY_ENABLE_RCON:-false}
        enforce-whitelist=${SERVER_PROPERTY_ENFORCE_WHITELIST:-false}
        force-gamemode=${SERVER_PROPERTY_FORCE_GAMEMODE:-false}
        function-permission-level=${SERVER_PROPERTY_FUNCTION_PERMISSION_LEVEL:-2}
        gamemode=${SERVER_PROPERTY_GAMEMODE:-0}
        generate-structures=${SERVER_PROPERTY_GENERATE_STRUCTURES:-true}
        generator-settings=${SERVER_PROPERTY_GENERATOR_SETTINGS}
        hardcore=${SERVER_PROPERTY_HARDCORE:-false}
        level-name=${SERVER_PROPERTY_LEVEL_NAME:-world}
        level-seed=${SERVER_PROPERTY_LEVEL_SEED}
        level-type=${SERVER_PROPERTY_LEVEL_TYPE:-DEFAULT}
        max-build-height=${SERVER_PROPERTY_MAX_BUILD_HEIGHT:-256}
        max-players=${SERVER_PROPERTY_MAX_PLAYERS:-20}
        max-tick-time=${SERVER_PROPERTY_MAX_TICK_TIME:-60000}
        max-world-size=${SERVER_PROPERTY_MAX_WORLD_SIZE:-29999984}
        motd=${SERVER_PROPERTY_MOTD:-A Minecraft Server}
        network-compression-threshold=${SERVER_PROPERTY_NETWORK_COMPRESSION_THRESHOLD:-256}
        online-mode=${SERVER_PROPERTY_ONLINE_MODE:-true}
        op-permission-level=${SERVER_PROPERTY_OP_PERMISSION_LEVEL:-4}
        player-idle-timeout=${SERVER_PROPERTY_PLAYER_IDLE_TIMEOUT:-0}
        prevent-proxy-connections=${SERVER_PROPERTY_PREVENT_PROXY_CONNECTIONS:-false}
        pvp=${SERVER_PROPERTY_PVP:-true}
        query.port=${SERVER_PROPERTY_QUERY_PORT:-25565}
        rcon.password=${SERVER_PROPERTY_RCON_PASSWORD}
        rcon.port=${SERVER_PROPERTY_RCON_PORT:-25575}
        resource-pack=${SERVER_PROPERTY_RESOURCE_PACK}
        resource-pack-sha1=${SERVER_PROPERTY_RESOURCE_PACK_SHA1}
        server-ip=${SERVER_PROPERTY_SERVER_IP}
        server-port=${SERVER_PROPERTY_SERVER_PORT:-25565}
        snooper-enabled=${SERVER_PROPERTY_SNOOPER_ENABLED:-true}
        spawn-animals=${SERVER_PROPERTY_SPAWN_ANIMALS:-true}
        spawn-monsters=${SERVER_PROPERTY_SPAWN_MONSTERS:-true}
        spawn-npcs=${SERVER_PROPERTY_SPAWN_NPCS:-true}
        spawn-protection=${SERVER_PROPERTY_SPAWN_PROTECTION:-16}
        view-distance=${SERVER_PROPERTY_VIEW_DISTANCE:-10}
        white-list=${SERVER_PROPERTY_WHITE_LIST:-false}
EOF
fi

# check if eula.txt exists, when not make it
FILE=/opt/mcserver/server/eula.txt
if [[ ! -f "$FILE" ]]; then
    cat <<- EOF >/opt/mcserver/server/eula.txt
        #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
        #Sun Apr 05 20:18:45 CEST 2020
        eula=${EULA:-false}
EOF
fi

# create RUN.sh
cat <<- EOF >/opt/mcserver/server/RUN.sh
    cd /opt/mcserver/server
    java \
        -XX:+UseG1GC \
        -XX:+UseFastAccessorMethods \
        -XX:+OptimizeStringConcat \
        -XX:+AggressiveOpts \
        -XX:+UseStringDeduplication \
        -XX:StringTableSize=1000003 \
        -XX:MetaspaceSize=512m \
        -XX:MaxMetaspaceSize=4096m \
        -XX:MaxGCPauseMillis=50 \
        -Xms${JAVA_XMS:-4096M} \
        -Xmx${JAVA_XMX:-5120M} \
        -XX:hashCode=5 \
        -Dfile.encoding=UTF-8 \
        -jar run.jar \
        --log-strip-color \
        --noconsole \
        nogui \
        --bonuschest
EOF
# make RUN.sh executable
chmod +x /opt/mcserver/server/RUN.sh

# check if git repo is set (Backup Script)
if [[ $MC_GINA_GIT_REPO ]]; then
	# GINAvbs backup solution
    cd /opt/mcserver/server
	echo "ciscocisco" | su -c "wget -qO- https://raw.githubusercontent.com/kleberbaum/GINAvbs/master/init.sh \
	| bash -s -- \
	--interval=$MC_GINA_INTERVAL \
	--repository=https://$MC_GINA_GIT_USER:$MC_GINA_GIT_PASSWD@${MC_GINA_GIT_REPO#*@}"
fi

# disable root
echo "ciscocisco" | su -c "chmod u-s /bin/su"

# execute CMD[]
exec "$@"