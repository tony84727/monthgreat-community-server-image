FROM alpine:3.13.5 AS compile-installer
ADD https://github.com/tony84727/minecraft-mod-installer/archive/refs/tags/v0.1.1.zip installer.zip
RUN apk add --update unzip cargo openssl-dev
RUN unzip installer.zip
WORKDIR /minecraft-mod-installer-0.1.1
RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/root/.cargo/git --mount=type=cache,target=target cargo build --release && cp target/release/minecraft-mod-installer /tmp/minecraft-mod-installer

FROM alpine:3.13.5 AS download

RUN apk add --update openjdk11 unzip bash libgcc
WORKDIR /tmp
ARG atmDownloadLink="https://media.forgecdn.net/files/3817/837/Server-Files-0.4.9.zip"
ARG atmVersion="0.4.9"
ADD ${atmDownloadLink} server.zip
RUN unzip server.zip && mv /tmp/Server-Files-${atmVersion} /tmp/server-files
WORKDIR /tmp/server-files
RUN echo "eula=true" > eula.txt
RUN java -jar forge-1.18.2-40.1.31-installer.jar --installServer

FROM openjdk:18-jdk
COPY --from=download /tmp/server-files /var/server
WORKDIR /var/server
ADD server.properties server.properties
VOLUME [ "/var/server/world" ]
VOLUME [ "/var/server/backups" ]
ENV MEMORY="12G"
RUN sed -i 's/^java/java -Xmx\$MEMORY/' ./run.sh
CMD ["./run.sh"]