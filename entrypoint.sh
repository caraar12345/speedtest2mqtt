#!/usr/bin/env bashio
CRON_CONFIG=$(bashio::config 'cron')
CRON=${CRON_CONFIG:="0 * * * *"}
echo "speedtest2mqtt has been started"

declare | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID|undefined' > /var/tmp/container.env
sed -i "/schedule/c\    schedule: \"${CRON}\"" /config/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /config/crontab.yml
