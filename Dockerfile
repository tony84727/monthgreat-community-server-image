FROM alpine:3.7 AS build_archon

RUN apk add openjdk8
ADD Archon /source
WORKDIR /source
RUN ./gradlew build

FROM alpine:3.7 AS download

RUN apk add --no-cache unzip

ADD https://github.com/ET-Team/EnigTech2/releases/download/v1.4.0/EnigTech2-1.4.0-Server.zip server.zip
ADD https://github.com/ET-Team/EnigTech2/releases/download/v1.4.0/ET2.v1.4.0.Additional_Mod_Package.zip dlc.zip

RUN unzip server.zip
RUN mv /EnigTech2-1.4.0-本体-Server /data && rm /data/*.jar && (cd /data/mods && unzip /dlc.zip)
ADD https://media.forgecdn.net/files/2785/465/Forgelin-1.8.4.jar /data/mods/Foreglin-1.8.4.jar
COPY --from=build_archon /source/build/libs/archon-1.0.jar /data/mods/archon.jar
RUN sed -ri '/levelCap/ s/30/100/g' /data/config/astralsorcery.cfg && chown 1000:1000 -R /data

FROM itzg/minecraft-server:latest

COPY --from=download /data /data

ENV VERSION="1.12.2"
ENV TYPE="FORGE"
ENV FORGEVERSION="14.23.5.2847"
ENV USE_AIKAR_FLAGS=true
