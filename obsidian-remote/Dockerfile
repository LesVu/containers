FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# Set version label
ARG TARGETARCH
ARG OBSIDIAN_VERSION=1.7.4

# Environment variables
ENV TITLE="Obsidian v${OBSIDIAN_VERSION}" \
    FM_HOME="/vaults" \
    CUSTOM_PORT=3000 \
    CUSTOM_USER="abc"

# Update and install extra packages
RUN echo '**** install packages ****' \
  && apt-get update \
  && apt-get install -y --no-install-recommends curl libnss3 zlib1g-dev dbus-x11 uuid-runtime libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 desktop-file-utils fonts-noto-color-emoji git ssh-askpass libfuse2 \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download and install Obsidian
RUN echo '**** download obsidian ****' \
  && [ "$TARGETARCH" = "amd64" ] \
  && curl -L -o /obsidian.AppImage "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage" \
  || [ "$TARGETARCH" = "arm64" ] \
  && curl -L -o /obsidian.AppImage "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}-${TARGETARCH}.AppImage" \
  && echo -e '#!/bin/bash\n/obsidian.AppImage --disable-gpu --no-sandbox' > /usr/local/bin/obsidian \
  && chmod +x /obsidian.AppImage /usr/local/bin/obsidian

# Add local files
COPY root/ /

# Expose ports and volumes
EXPOSE 3000 3001
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD /bin/sh -c 'if [ -z "$CUSTOM_USER" ] || [ -z "$PASSWORD" ]; then curl --fail http://localhost:${CUSTOM_PORT}/ || exit 1; else curl --fail --user "$CUSTOM_USER:$PASSWORD" http://localhost:${CUSTOM_PORT}/ || exit 1; fi'
