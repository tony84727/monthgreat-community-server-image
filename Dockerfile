FROM alpine:3.12.4 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/tags/v0.1.1.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-0.1.1
RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git --mount=type=cache,target=target cargo build --release && cp target/release/minecraft-mod-installer /tmp/minecraft-mod-installer

FROM alpine:3.12.4 AS download

RUN apk add --update openjdk11 unzip bash libgcc
WORKDIR /tmp
ARG atmVersion="1.6.0b"
ARG atmDownloadLink="https://media.forgecdn.net/files/3278/552/SIMPLE-SERVER-FILES-1.6.0b.zip"
ADD ${atmDownloadLink} server.zip
RUN unzip server.zip && mv /tmp/SIMPLE-SERVER-FILES-${atmVersion} /tmp/server-files
WORKDIR /tmp/server-files
RUN echo "eula=true" > eula.txt
COPY --from=compile-installer /tmp/minecraft-mod-installer minecraft-mod-installer
RUN chmod +x ./minecraft-mod-installer && ./minecraft-mod-installer
ADD https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.5-36.1.2/forge-1.16.5-36.1.2-installer.jar forge-installer.jar
RUN java -jar forge-installer.jar --installServer

FROM alpine:3.12.4
RUN apk add --update --no-cache openjdk11 emacs zip unzip bash
COPY --from=download /tmp/server-files /var/server
WORKDIR /var/server
ADD quark-common.toml config/quark-common.toml
ADD https://github.com/tony84727/xp-tweak/releases/download/v1.2.0/xptweak-1.2.0-26.jar mods/xptweak-1.2.0-26.jar
ADD server.properties server.properties
VOLUME [ "/var/server/world" ]
VOLUME [ "/var/server/backups" ]
ENV JVM_OPTS="-server \
-XX:+UseG1GC \
-XX:+ParallelRefProcEnabled \
-XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions \
-XX:+DisableExplicitGC \
-XX:+AlwaysPreTouch \
-XX:G1NewSizePercent=30 \
-XX:G1MaxNewSizePercent=40 \
-XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 \
-XX:G1HeapWastePercent=5 \
-XX:G1MixedGCCountTarget=4 \
-XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 \
-XX:G1RSetUpdatingPauseTimePercent=5 \
-XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem \
-XX:MaxTenuringThreshold=1 \
-Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true \
-Dfml.readTimeout=90 \
-Dfml.queryResult=confirm"
ENV MEMORY="12G"
CMD java ${JVM_OPTS} -Xmx${MEMORY} -jar forge-1.16.5-36.1.2.jar nogui