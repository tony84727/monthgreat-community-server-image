FROM alpine:3.7 AS download

RUN apk add --no-cache unzip

ADD https://github.com/ET-Team/EnigTech2/releases/download/v1.4.0/EnigTech2-1.4.0-Server.zip server.zip

RUN unzip server.zip

FROM alpine:3.7 AS build_archon

RUN apk add openjdk8
ADD archon /source
WORKDIR /source
RUN ./gradlew build

FROM itzg/minecraft:latest

VOLUME [ "/data/world" ]
COPY --from=download EnigTech2-1.4.0-掛极-Server /data
COPY --from=build_archon /source/build/libs/archon-1.0.jar /data/mods/archon.jar
ADD https://media.forgecdn.net/files/2785/465/Forgelin-1.8.4.jar /data/mods/Foreglin-1.8.4.jar
ADD https://media.forgecdn.net/files/2947/622/LagGoggles-1.12.2-5.8-132.jar /data/mods/LagGoggles-1.12.2-5.8-132.jar
RUN sed -ri '/levelCap/ s/30/100/g' /data/config/astralsorcery.cfg 

ENV VERSION="1.12.2"
ENV TYPE="forge"
ENV FORGEVERSION="14.23.5.2847"
ENV JVM_XX_OPTS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=40 -XX:G1HeapRegionSize=32M -XX:G1MixedGCLiveThresholdPercent=50"
ENV JVM_DD_OPTS="fml.readTimeout:180 sun.rmi.dgc.server.gcInterval:2147483646"