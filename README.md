# Ookla Speedtest CLI

Home Assistant add-on that runs the official [Ookla Speedtest CLI](https://www.speedtest.net/apps/cli)
on a cron schedule and publishes the results (plus MQTT discovery config) to your MQTT broker.

MQTT credentials are taken from Home Assistant's own `mqtt` service via `bashio::services` -
there are no MQTT_HOST/MQTT_USER/etc. environment variables to set; configure the add-on
through its Options in the Home Assistant UI instead.

## Options

    mqtt_topic (Default 'homeassistant/speedtest')
    mqtt_options (Default '')
    cron (Default '0 * * * *' -> run the speed test once an hour)

## Published topics

Under `<mqtt_topic>`:

    /test              JSON blob with download, upload, ping, jitter, packetloss, server info, timestamp
    /download           Download speed (Mbps)
    /downraw            Raw download bandwidth (bytes/s, as reported by the CLI)
    /upload             Upload speed (Mbps)
    /upraw              Raw upload bandwidth (bytes/s, as reported by the CLI)
    /ping               Ping latency (ms)
    /jitter             Ping jitter (ms)
    /packetloss         Packet loss (%)
    /server/id          Test server ID
    /server/name        Test server name
    /server/location    Test server location
    /server/host        Test server host
    /server/country     Test server country
    /timestamp          Timestamp of the test

MQTT discovery configs are also published (under the standard `homeassistant/sensor/...`
discovery prefix, not `<mqtt_topic>`) for the download, upload, ping, jitter and packet loss
sensors so Home Assistant will pick them up automatically.

## Supported architectures

i386, amd64, armhf and aarch64.

## Note

This docker image uses the [Ookla Speedtest CLI](https://www.speedtest.net/apps/cli) and
automatically accepts the Ookla License and GDPR terms.

## Ookla speedtest License

You may only use this Speedtest software and information generated from it for personal,
non-commercial use, through a command line interface on a personal computer. Your use of this
software is subject to the End User License Agreement, Terms of Use and Privacy Policy at these
URLs:

https://www.speedtest.net/about/eula
https://www.speedtest.net/about/terms
https://www.speedtest.net/about/privacy
