FROM alpine:3.12.4 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/heads/main.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-main
RUN cargo build --release

FROM alpine:3.12.4 AS download

RUN apk add --update openjdk8 unzip bash
WORKDIR /tmp
ADD https://media.forgecdn.net/files/3249/362/SIMPLE-SERVER-FILES-1.5.6.zip server.zip
RUN unzip server.zip
WORKDIR /tmp/SIMPLE-SERVER-FILES-1.5.6
RUN echo "eula=true" > eula.txt
COPY --from=compile-installer /minecraft-mod-installer-main/target/release/minecraft-mod-installer minecraft-mod-installer
RUN chmod +x ./minecraft-mod-installer && ./minecraft-mod-installer
ADD https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.5-36.1.2/forge-1.16.5-36.1.2-installer.jar forge-installer.jar
RUN java -jar forge-installer.jar --installServer

FROM alpine:3.12.4
RUN apk add --update --no-cache openjdk8 emacs zip unzip bash
COPY --from=download /tmp/SIMPLE-SERVER-FILES-1.5.6 /var/server
WORKDIR /var/server
ADD quark-common.toml config/quark-common.toml
ADD https://media.forgecdn.net/files/3245/792/spark-forge.jar mods/spark-forge.jar
ADD https://github.com/tony84727/xp-tweak/releases/download/1.0/xptweak-1.0-7.jar mods/xptweak-1.0-7.jar
ADD https://github.com/tony84727/Apotheosis/releases/download/4.4.1-p1/Apotheosis-1.16.3-4.4.1.jar mods/Apotheosis-1.16.3-4.4.1.jar
ADD server.properties server.properties
VOLUME [ "/var/server/world" ]
VOLUME [ "/var/server/backups" ]
ENV JVM_OPTS="-XX:+AggressiveOpts \
-XX:ParallelGCThreads=4 \
-XX:+UseConcMarkSweepGC \
-XX:+UnlockExperimentalVMOptions \
-XX:+UseParNewGC \
-XX:+ExplicitGCInvokesConcurrent \
-XX:MaxGCPauseMillis=10 \
-XX:GCPauseIntervalMillis=50 \
-XX:+UseFastAccessorMethods \
-XX:+OptimizeStringConcat \
-XX:NewSize=84m \
-XX:+UseAdaptiveGCBoundary \
-XX:NewRatio=3 \
-Dfml.readTimeout=300 \
-Dfml.queryResult=confirm"
ENV MEMORY="12G"
CMD java ${JVM_OPTS} -Xmx${MEMORY} -jar forge-1.16.5-36.1.2.jar nogui