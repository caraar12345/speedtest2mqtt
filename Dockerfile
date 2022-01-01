ARG BUILD_FROM
ARG TARGETARCH
FROM ${BUILD_FROM}

COPY entrypoint.sh speedtest2mqtt.sh /opt/
COPY crontab.yml /home/foo/

RUN addgroup -S foo && adduser -S foo -G foo && \
    chmod +x /opt/speedtest2mqtt.sh /opt/entrypoint.sh && \
    chown foo:foo /home/foo/crontab.yml && \
    apk --no-cache add bash mosquitto-clients jq python3

RUN apk --no-cache add wget --virtual .build-deps && \
    echo "Target Arch $TARGETARCH" && \
    wget https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-x86_64-linux.tgz -O /var/tmp/speedtest.tar.gz && \
    tar xf /var/tmp/speedtest.tar.gz -C /var/tmp && \
    mv /var/tmp/speedtest /usr/local/bin && \
    rm /var/tmp/speedtest.tar.gz && \
    apk del --no-cache .build-deps

RUN apk --no-cache add gcc musl-dev python3-dev --virtual .build-deps && \
    python3 -m venv yacronenv && \
    . yacronenv/bin/activate && \
    pip install yacron && \
    apk del --no-cache .build-deps

USER foo
ENTRYPOINT /opt/entrypoint.sh

