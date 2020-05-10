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
ADD https://media.forgecdn.net/files/2947/231/TickCentral-2.6.jar /data/mods/TickCentral-2.6.jar
ADD https://media.forgecdn.net/files/2947/622/LagGoggles-1.12.2-5.8-132.jar /data/mods/LagGoggles-1.12.2-5.8-132.jar
COPY --from=build_archon /source/build/libs/archon-1.0.jar /data/mods/archon.jar
RUN find /data/mods -type f  -exec chmod 644 {} \; && find /data/mods -type d -exec chmod 755 {} \;

# change config
RUN sed -ri '/levelCap/ s/30/100/g' /data/config/astralsorcery.cfg
RUN sed -ri '/SleeperPerc/ s/50/1/g;' /data/config/morpheus.cfg
RUN sed -ri '/Costs? XP/ s/true/false/g;/XP Cost/ s/3/0/g' /data/config/Waystones.cfg

FROM itzg/minecraft-server:latest
COPY --from=download --chown=minecraft /data/mods /data/mods
COPY --from=download --chown=minecraft /data/libraries /data/libraries
COPY --from=download --chown=minecraft /data/patchouli_books /data/patchouli_books
COPY --from=download --chown=minecraft /data/resources /data/resources
COPY --from=download --chown=minecraft /data/scripts /data/scripts
COPY --from=download --chown=minecraft /data/config /data/config
ADD ranks.txt /data/local/ftbutilities/ranks.txt

ENV VERSION="1.12.2" \
TYPE="FORGE" \
FORGEVERSION="14.23.5.2847" \
USE_AIKAR_FLAGS=true \
DIFFICULTY=3 \
LEVEL_TYPE=BIOMESOP \
ALLOW_FLIGHT=TRUE \
MAX_TICK_TIME=180000
