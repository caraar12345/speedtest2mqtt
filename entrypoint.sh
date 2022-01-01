#!/bin/bash
CONFIG_PATH="/data/options.json"
CRON=${`jq --raw-output '.cron // empty'`:-0 * * * *}
echo "speedtest2mqtt has been started "

declare | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /var/tmp/container.env
sed -i "/schedule/c\    schedule: \"${CRON}\"" /home/foo/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /home/foo/crontab.yml