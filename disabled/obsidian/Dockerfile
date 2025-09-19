FROM debian:sid AS base
ARG OBSIDIAN_VERSION=1.9.12

ENV USER=obsidian
ENV DEBIAN_FRONTEND=noninteractive
ENV WLR_RENDER_DRM_DEVICE=/dev/dri/renderD128

RUN apt-get update \
  && apt-get full-upgrade -y -q \
  && apt-get install -q -y --no-install-recommends --no-install-suggests \
  curl locales \
  ca-certificates git websockify gosu \
  && apt-get install -q -y --no-install-recommends --no-install-suggests wayvnc cage wl-clipboard \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -G video,audio ${USER}

RUN sed -i "s/# \(en_US\.UTF-8 .*\)/\1/" /etc/locale.gen \
  && locale-gen

RUN cd /home/${USER} \
  && git clone https://github.com/novnc/noVNC --depth 1

RUN curl -L https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb -o obsidian.deb \
  && apt-get update \
  && apt-get install -f -q -y --no-install-recommends --no-install-suggests ./obsidian.deb \
  && rm -rf /var/lib/apt/lists/* \
  && rm obsidian.deb

RUN find /home/${USER} -not -user ${USER} -exec chown ${USER}:${USER} {} \;

COPY start.sh /start.sh

WORKDIR /home/${USER}
CMD [ "/start.sh" ]
EXPOSE 5900 6100
