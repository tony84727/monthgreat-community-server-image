FROM alpine:3.13.5 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/tags/v0.1.1.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-0.1.1
RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git --mount=type=cache,target=target cargo build --release && cp target/release/minecraft-mod-installer /tmp/minecraft-mod-installer

FROM alpine:3.13.5 AS download

RUN apk add --update openjdk11 unzip bash libgcc
WORKDIR /tmp
ARG atmVersion="0.4.0"
ARG atmDownloadLink="https://media.forgecdn.net/files/3793/375/SIMPLE-SERVER-FILES-0.4.0.zip"
ADD ${atmDownloadLink} server.zip
RUN unzip server.zip && mv /tmp/SIMPLE-SERVER-FILES-${atmVersion} /tmp/server-files
WORKDIR /tmp/server-files
RUN echo "eula=true" > eula.txt
COPY --from=compile-installer /tmp/minecraft-mod-installer minecraft-mod-installer
RUN chmod +x ./minecraft-mod-installer && ./minecraft-mod-installer
ADD https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.1.16/forge-1.18.2-40.1.16-installer.jar forge-installer.jar
RUN java -jar forge-installer.jar --installServer

FROM openjdk:18-jdk
# RUN apt install --update --no-cache emacs zip unzip bash libstdc++
COPY --from=download /tmp/server-files /var/server
WORKDIR /var/server
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
	-Dfml.readTimeout=90 \
	-Dfml.queryResult=confirm"
ENV MEMORY="12G"
RUN sed -i 's/^java/java -Xmx\$MEMORY/' ./run.sh
CMD ["./run.sh"]