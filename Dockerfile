FROM golang:1.23rc1

ENV HOME /root

EXPOSE 8000

RUN apt-get update -y \
    && apt-get install -y wget build-essential git mercurial rsync unzip

ARG CESIUM_VERSION=1.8
ENV CESIUM_VERSION=${CESIUM_VERSION}

RUN mkdir -p /tmp/cesium /var/www/cesium \
    && cd /tmp/cesium \
    && wget --no-verbose --directory-prefix=/tmp/local https://github.com/CesiumGS/cesium/releases/download/${CESIUM_VERSION}/Cesium-${CESIUM_VERSION}.zip \
    && unzip -q /tmp/local/Cesium-${CESIUM_VERSION}.zip \
    && mv Apps ThirdParty Build /var/www/cesium/

COPY . /go/src/terrain-server
WORKDIR /go/src/terrain-server

RUN go install github.com/go-bindata/go-bindata/go-bindata@latest \
    && make install \
    && go get github.com/geo-data/cesium-terrain-server/cmd/cesium-terrain-server

RUN cp -a docker/root-fs/* /

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/etc/sv/terrain-server/run"]
