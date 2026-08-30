#!/usr/bin/env bashio
CRON_CONFIG=$(bashio::config 'cron')
CRON=${CRON_CONFIG:="0 * * * *"}
echo "speedtest2mqtt has been started"

mkdir -p /etc/crontabs
echo "${CRON} /opt/speedtest2mqtt.sh > /proc/1/fd/1 2> /proc/1/fd/2" > /etc/crontabs/root

echo "starting cron (${CRON})"
exec crond -f -d 8
