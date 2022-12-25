#!/usr/bin/env bashio
CRON_CONFIG=$(bashio::config 'cron')
CRON=${CRON_CONFIG:="0 * * * *"}
echo "speedtest2mqtt has been started"

sed -i "/schedule/c\    schedule: \"${CRON}\"" /config/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /config/crontab.yml
