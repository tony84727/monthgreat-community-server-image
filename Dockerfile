FROM alpine:3.7 AS download

RUN apk add --no-cache unzip

ADD https://media.forgecdn.net/files/3062/577/CrafttoExile-Dissonance-2.4.2c-SERVER.zip server.zip

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
JVM_XX_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
