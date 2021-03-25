FROM alpine:3.12.4 AS download

RUN apk add --update openjdk8 unzip bash
WORKDIR /tmp
ADD https://media.forgecdn.net/files/3249/362/SIMPLE-SERVER-FILES-1.5.6.zip server.zip
RUN unzip server.zip
WORKDIR /tmp/SIMPLE-SERVER-FILES-1.5.6
ADD https://github.com/BloodyMods/ServerStarter/releases/download/v1.2.7/serverstarter-1.2.7.jar serverstarter-1.2.7.jar
RUN chmod +x "./startserver.sh"
RUN echo "eula=true" > eula.txt
RUN java -jar serverstarter-1.2.7.jar install 

FROM alpine:3.12.4
RUN apk add --update --no-cache openjdk8 emacs zip unzip bash
COPY --from=download /tmp/SIMPLE-SERVER-FILES-1.5.6 /var/server
WORKDIR /var/server
ADD quark-common.toml config/quark-common.toml
ADD https://media.forgecdn.net/files/3245/792/spark-forge.jar mods/spark-forge.jar
ADD https://github.com/tony84727/xp-tweak/releases/download/1.0/xptweak-1.0-7.jar mods/xptweak-1.0-7.jar
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