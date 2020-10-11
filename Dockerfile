FROM alpine:3.7 AS download

RUN apk add --no-cache unzip

ADD https://media.forgecdn.net/files/3074/891/CrafttoExile-Dissonance-2.5.2b-SERVER.zip server.zip

RUN mkdir files && cd files && unzip /server.zip

FROM itzg/minecraft-server:adopt11
COPY --from=download --chown=minecraft /files /data

ENV VERSION="1.15.2" \
TYPE="FORGE" \
FORGEVERSION="31.2.36" \
DIFFICULTY=3 \
LEVEL_TYPE=DEFAULT \
ALLOW_FLIGHT=TRUE \
MAX_TICK_TIME=180000 \
JVM_DD_OPTS="fml.readTimeout:180 sun.rmi.dgc.server.gcInterval:2147483646" \
JVM_XX_OPTS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=40 -XX:G1HeapRegionSize=32M -XX:G1MixedGCLiveThresholdPercent=50"
