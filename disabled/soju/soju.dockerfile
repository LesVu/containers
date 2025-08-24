FROM golang:1.23.4-alpine3.21 AS build

ENV SOJU_VERSION v0.8.2

RUN apk update && apk add --no-cache git make build-base
  
WORKDIR /

RUN git clone https://codeberg.org/emersion/soju.git && \
  cd soju && \
  git checkout $SOJU_VERSION && \
  make soju

FROM alpine:3.21

COPY --from=build /soju/soju /usr/bin/soju
COPY --from=build /soju/sojudb /usr/bin/sojudb
COPY --from=build /soju/sojuctl /usr/bin/sojuctl

RUN mkdir -p /run/soju/

VOLUME /soju/
VOLUME /etc/soju/config

CMD ["soju"]
