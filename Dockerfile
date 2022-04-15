FROM alpine:3.13.5 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/tags/v0.1.1.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-0.1.1
RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git --mount=type=cache,target=target cargo build --release && cp target/release/minecraft-mod-installer /tmp/minecraft-mod-installer

FROM alpine:3.13.5 AS download

RUN apk add --update openjdk11 unzip bash libgcc
WORKDIR /tmp
ARG atmVersion="0.3.7"
ARG atmDownloadLink="https://media.forgecdn.net/files/3751/996/SIMPLE-SERVER-FILES-0.3.7.zip"
ADD ${atmDownloadLink} server.zip
RUN unzip server.zip && mv /tmp/SIMPLE-SERVER-FILES-${atmVersion} /tmp/server-files
WORKDIR /tmp/server-files
RUN echo "eula=true" > eula.txt
COPY --from=compile-installer /tmp/minecraft-mod-installer minecraft-mod-installer
RUN chmod +x ./minecraft-mod-installer && ./minecraft-mod-installer
ADD https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.0.52/forge-1.18.2-40.0.52-installer.jar forge-installer.jar
RUN java -jar forge-installer.jar --installServer

FROM openjdk:17-jdk
# RUN apt install --update --no-cache emacs zip unzip bash libstdc++
COPY --from=download /tmp/server-files /var/server
WORKDIR /var/server
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
ADD run.sh .
RUN chmod +x run.sh
CMD ./run.sh