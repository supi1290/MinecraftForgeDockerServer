#!/usr/bin/env bash

# terminate on errors
set -xe

# define as docker compose var or default ""
TS_GINA_GIT_REPO=${TS_GINA_GIT_REPO:-""}
TS_GINA_GIT_USER=${TS_GINA_GIT_USER:-""}
TS_GINA_GIT_PASSWD=${TS_GINA_GIT_PASSWD:-""}
TS_GINA_INTERVAL=${TS_GINA_INTERVAL:-""}

# Download and unzip server.zip if no server datei was found
DIR="/opt/mcserver/server/"
if [ ! -d "$DIR" ]; then
    echo "## Download and unzip server ##"
    echo "ciscocisco" | su -c "mkdir /opt/mcserver/server"
    cd /opt/mcserver/server
    echo "ciscocisco" | su -c "wget ${MODPACK_URL}"
    echo "ciscocisco" | su -c "unzip  ${MODPACK_FILENAME}"
    echo "ciscocisco" | su -c "rm ${MODPACK_FILENAME}"
fi

# check if server.properties file exists, when not make it
FILE=/opt/mcserver/server/server.properties
if [[ ! -f "$FILE" ]]; then
    echo "ciscocisco" | su -c "cat <<- EOF >/opt/mcserver/server/server.properties
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
EOF"
fi

# check if eula.txt exists, when not make it
FILE=/opt/mcserver/server/eula.txt
if [[ ! -f "$FILE" ]]; then
    echo "ciscocisco" | su -c "cat <<- EOF >/opt/mcserver/server/eula.txt
        #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
        eula=${EULA:-false}
EOF "
fi

# check if git repo is set (Backup Script)
if [[ $TS_GINA_GIT_REPO ]]; then
	# GINAvbs backup solution
	echo "ciscocisco" | su -c "wget -qO- https://raw.githubusercontent.com/kleberbaum/GINAvbs/master/init.sh \
	| bash -s -- \
	--interval=$TS_GINA_INTERVAL \
	--repository=https://$TS_GINA_GIT_USER:$TS_GINA_GIT_PASSWD@${TS_GINA_GIT_REPO#*@}"
fi

# disable root
echo "ciscocisco" | su -c "chmod u-s /bin/su"

# execute server
cd /opt/mcserver/server
args=()
if [[ ${JAVA_XX_USEG1GC:-false} == "true" ]]; then
	args+=("-XX:+UseG1GC")
fi
if [[ ${JAVA_XX_USEFASTACCESSORMETHODS:-false} == "true"  ]]; then
	args+=("-XX:+UseFastAccessorMethods")
fi
if [[ ${JAVA_XX_OPTIMIZESTRINGCONCAT:-false} == "true"  ]]; then
	args+=("-XX:+OptimizeStringConcat")
fiF
if [[ ${JAVA_XX_AGGRESSIVEOPTS:-false} == "true"  ]]; then
	args+=("-XX:+AggressiveOpts")
fi
if [[ ${JAVA_XX_USESTRINGDEDUPLICATION:-false} == "true"  ]]; then
	args+=("-XX:+UseStringDeduplication")
fi
if [[ ${JAVA_XX_STRINGTABLESIZE} ]]; then
	args+=("-XX:StringTableSize=${JAVA_XX_STRINGTABLESIZE}")
fi
if [[ ${JAVA_XX_METASPACESIZE} ]]; then
	args+=("-XX:MetaspaceSize=${JAVA_XX_METASPACESIZE}")
fi
if [[ ${JAVA_XX_MAXMETASPACESIZE} ]]; then
	args+=("-XX:MaxMetaspaceSize=${JAVA_XX_MAXMETASPACESIZE}")
fi
if [[ ${JAVA_XX_MAXGCPAUSEMILLIS} ]]; then
	args+=("-XX:MaxGCPauseMillis=${JAVA_XX_MAXGCPAUSEMILLIS}")
fi
if [[ ${JAVA_XMS} ]]; then
	args+=("-Xms${JAVA_XMS}")
fi
if [[ ${JAVA_XMX} ]]; then
	args+=("-Xmx${JAVA_XMX}")
fi
if [[ ${JAVA_XX_HASHCODE} ]]; then
	args+=("-XX:hashCode=${JAVA_XX_HASHCODE}")
fi
if [[ ${JAVA_DFILE_ENCODING} ]]; then
	args+=("-Dfile.encoding=${JAVA_DFILE_ENCODING}")
fi
args+=("-jar ${JAVA_FILE_NAME:-run.jar}")
if [[ ${JAVA_LOG_STRIP_COLOR:-false} == "true"  ]]; then
	args+=("--log-strip-color")
fi
if [[ ${JAVA_NOCONSOLE:-false} == "true"  ]]; then
	args+=("--noconsole")
fi
# Forge specific arguments
if [[ ${JAVA_FORGE_PORT} ]]; then
    args+=("--port ${JAVA_FORGE_PORT}")
fi
if [[ ${JAVA_FORGE_SINGLEPLAYER} ]]; then
    args+=("--singleplayer ${JAVA_FORGE_SINGLEPLAYER}")
fi
if [[ ${JAVA_FORGE_UNIVERSE} ]]; then
    args+=("--universe ${JAVA_FORGE_UNIVERSE}")
fi
if [[ ${JAVA_FORGE_WORLD} ]]; then
    args+=("--world ${JAVA_FORGE_WORLD}")
fi
if [[ ${JAVA_FORGE_DEMO:-false} == "true"  ]]; then
	args+=("--demo")
fi
if [[ ${JAVA_FORGE_BONUSCHEST:-false} == "true"  ]]; then
	args+=("--bonuschest")
fi
if [[ ${JAVA_FORGE_NOGUI:-false} == "true"  ]]; then
	args+=("nogui")
fi

exec "java ${args[@]}";