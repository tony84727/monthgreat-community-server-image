FROM alpine:3.12.4 AS download

RUN apk add --update openjdk8 unzip bash
WORKDIR /tmp
ADD https://media.forgecdn.net/files/3249/362/SIMPLE-SERVER-FILES-1.5.6.zip server.zip
RUN unzip server.zip
WORKDIR /tmp/SIMPLE-SERVER-FILES-1.5.6
ADD https://github.com/BloodyMods/ServerStarter/releases/download/v1.2.7/serverstarter-1.2.7.jar serverstarter-1.2.7.jar
RUN chmod +x "./startserver.sh"

FROM alpine:3.12.4
RUN apk add --update --no-cache openjdk8 emacs zip unzip bash
COPY --from=download /tmp/SIMPLE-SERVER-FILES-1.5.6 /var/server
WORKDIR /var/server
ADD quark-common.toml config/quark-common.toml
ADD https://media.forgecdn.net/files/3245/792/spark-forge.jar mods/spark-forge.jar
ADD https://github.com/tony84727/xp-tweak/releases/download/1.0/xptweak-1.0-7.jar mods/xptweak-1.0-7.jar
RUN echo "eula=true" > eula.txt
VOLUME [ "/var/server/world" ]
CMD [ "./startserver.sh"]