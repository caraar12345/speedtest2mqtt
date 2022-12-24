ARG BUILD_ARCH
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base
FROM ${BUILD_FROM}

COPY entrypoint.sh speedtest2mqtt.sh /opt/
COPY crontab.yml /config/crontab.yml

RUN chmod +x /opt/speedtest2mqtt.sh /opt/entrypoint.sh && \
    apk --no-cache add mosquitto-clients jq python3 zsh

SHELL ["/bin/zsh", "-c"]

RUN apk --no-cache add wget --virtual .build-deps

ARG BUILD_ARCH
RUN echo "Target Arch $BUILD_ARCH" && \
    if [[ $BUILD_ARCH = 'i386' ]]; then wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-i386.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [[ $BUILD_ARCH = 'amd64' ]]; then wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [[ $BUILD_ARCH = 'armhf' ]]; then wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armhf.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    if [[ $BUILD_ARCH = 'aarch64' ]]; then wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz -O /var/tmp/speedtest.tar.gz; fi && \
    tar xf /var/tmp/speedtest.tar.gz -C /var/tmp && \
    mv /var/tmp/speedtest /usr/local/bin && \
    rm /var/tmp/speedtest.tar.gz && \
    apk del --no-cache .build-deps

RUN apk --no-cache add gcc musl-dev python3-dev --virtual .build-deps && \
    python3 -m venv yacronenv && \
    . yacronenv/bin/activate && \
    pip install yacron && \
    apk del --no-cache .build-deps

ENTRYPOINT /opt/entrypoint.sh
