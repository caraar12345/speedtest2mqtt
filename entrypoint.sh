#!/bin/zsh
CONFIG_PATH="/data/options.json"
CRON=${$(jq --raw-output '.cron // empty' $CONFIG_PATH):-"0 * * * *"}
echo "speedtest2mqtt has been started"

sed -i "/schedule/c\    schedule: \"${CRON}\"" /home/foo/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /home/foo/crontab.yml