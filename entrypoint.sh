#!/bin/zsh
CONFIG_PATH="/data/options.json"
CRON=${$(jq --raw-output '.cron // empty' $CONFIG_PATH):-"0 * * * *"}
echo "speedtest2mqtt has been started"

declare | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /var/tmp/container.env
sed -i "/schedule/c\    schedule: \"${CRON}\"" /config/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /config/crontab.yml