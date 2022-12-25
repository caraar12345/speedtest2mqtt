ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable
FROM $BUILD_FROM

ARG TARGETVARIANT
ARG TARGETARCH
ARG BUILD_ARCH=$TARGETARCH

ARG BUILD_TIME
ARG BUILD_REVISION
ARG BUILD_VERSION
ARG SPEEDTEST_URL_TEMPLATE
ARG SPEEDTEST_VERSION
ARG SPEEDTEST_URL=${SPEEDTEST_URL_TEMPLATE}${SPEEDTEST_VERSION}-linux

COPY entrypoint.sh speedtest2mqtt.sh /opt/
COPY crontab.yml /config/crontab.yml

RUN chmod +x /opt/speedtest2mqtt.sh /opt/entrypoint.sh && \
    apk --no-cache add gcc musl-dev python3-dev --virtual .build-deps && \
    apk --no-cache add mosquitto-clients jq python3 && \
    echo "Target Arch: $BUILD_ARCH" && \
    if [ $BUILD_ARCH = '386' ]; then wget ${SPEEDTEST_URL}-i386.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [ $BUILD_ARCH = 'amd64' ]; then wget ${SPEEDTEST_URL}-x86_64.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [ $BUILD_ARCH = 'arm' ] && [ $TARGETVARIANT = 'v6' ]; then wget ${SPEEDTEST_URL}-armel.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [ $BUILD_ARCH = 'arm' ] && [ $TARGETVARIANT = 'v7' ]; then wget ${SPEEDTEST_URL}-armhf.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [ $BUILD_ARCH = 'arm64' ]; then wget ${SPEEDTEST_URL}-aarch64.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    tar xf /var/tmp/speedtest.tar.gz -C /var/tmp && \
    mv /var/tmp/speedtest /usr/local/bin && \
    rm /var/tmp/* && \
    python3 -m venv yacronenv && \
    . yacronenv/bin/activate && \
    pip install yacron && \
    apk del --no-cache .build-deps

ENTRYPOINT /opt/entrypoint.sh

LABEL org.opencontainers.artifact.created $BUILD_TIME
LABEL org.opencontainers.image.created $BUILD_TIME
LABEL org.opencontainers.image.source https://github.com/caraar12345/home-assistant-addons
LABEL org.opencontinaers.image.authors "Aaron Carson <aaron@aaroncarson.co.uk>"
LABEL org.opencontainers.image.version $BUILD_VERSION
LABEL org.opencontainers.image.licenses "MIT"
LABEL org.opencontainers.image.revision $BUILD_REVISION
LABEL org.opencontainers.artifact.description "Ookla Speedtest CLI as a Home Assistant Add-on with the output being published to MQTT."
