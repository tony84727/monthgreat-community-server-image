FROM alpine:3.13.5 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/tags/v0.1.1.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-0.1.1
RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git --mount=type=cache,target=target cargo build --release && cp target/release/minecraft-mod-installer /tmp/minecraft-mod-installer

FROM alpine:3.13.5 AS download

RUN apk add --update openjdk11 unzip bash libgcc
WORKDIR /tmp
ARG atmVersion="1.6.2"
ARG atmDownloadLink="https://media.forgecdn.net/files/3287/544/SIMPLE-SERVER-FILES-1.6.2.zip"
ADD ${atmDownloadLink} server.zip
RUN unzip server.zip && mv /tmp/SIMPLE-SERVER-FILES-${atmVersion} /tmp/server-files
WORKDIR /tmp/server-files
RUN echo "eula=true" > eula.txt
COPY --from=compile-installer /tmp/minecraft-mod-installer minecraft-mod-installer
RUN chmod +x ./minecraft-mod-installer && ./minecraft-mod-installer
ADD https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.5-36.1.2/forge-1.16.5-36.1.2-installer.jar forge-installer.jar
RUN java -jar forge-installer.jar --installServer

FROM adoptopenjdk/openjdk14:alpine
RUN apk add --update --no-cache emacs zip unzip bash libstdc++
COPY --from=download /tmp/server-files /var/server
WORKDIR /var/server
ADD quark-common.toml config/quark-common.toml
ADD https://github.com/tony84727/xp-tweak/releases/download/v1.2.0/xptweak-1.2.0-26.jar mods/xptweak-1.2.0-26.jar
ADD server.properties server.properties
VOLUME [ "/var/server/world" ]
VOLUME [ "/var/server/backups" ]
ENV JVM_OPTS="-server \
-XX:+UnlockExperimentalVMOptions \
-XX:+UseZGC \
-XX:SurvivorRatio=32 \
-XX:MaxGCPauseMillis=50 \
-Dfml.readTimeout=90 \
-Dfml.queryResult=confirm"
ENV MEMORY="12G"
CMD java ${JVM_OPTS} -Xmx${MEMORY} -jar forge-1.16.5-36.1.2.jar nogui