#!/usr/bin/env bashio
set -uo pipefail

MQTT_HOST=$(bashio::services mqtt "host")
MQTT_PORT=$(bashio::services mqtt "port")
MQTT_USER=$(bashio::services mqtt "username")
MQTT_PASS=$(bashio::services mqtt "password")

MQTT_ID="speedtest-mqtt-hass"
MQTT_TOPIC=$(bashio::config 'mqtt_topic')
DISCOVERY_PREFIX="homeassistant"
# MQTT_OPTIONS is user-supplied, space-separated extra mosquitto_pub flags
# (e.g. "-r"), so it is intentionally split into an array rather than quoted.
read -ra MQTT_OPTIONS <<< "$(bashio::config 'mqtt_options')"

file=~/ookla.json

echo "$(date -Iseconds) starting speedtest"

if ! speedtest --accept-license --accept-gdpr -f json-pretty > "${file}"; then
  echo "$(date -Iseconds) speedtest failed, skipping this run"
  exit 1
fi

if ! jq -e '[.download.bandwidth, .upload.bandwidth, .ping.latency, .ping.jitter, .packetLoss] | all(type == "number")' "${file}" > /dev/null 2>&1; then
  echo "$(date -Iseconds) speedtest output missing required fields, skipping this run"
  exit 1
fi

downraw=$(jq -r '.download.bandwidth' "${file}")
download=$(printf %.2f\\n "$((downraw * 8))e-6")
upraw=$(jq -r '.upload.bandwidth' "${file}")
upload=$(printf %.2f\\n "$((upraw * 8))e-6")
ping=$(jq -r '.ping.latency' "${file}")
jitter=$(jq -r '.ping.jitter' "${file}")
packetloss=$(jq -r '.packetLoss' "${file}")
serverid=$(jq -r '.server.id' "${file}")
servername=$(jq -r '.server.name' "${file}")
servercountry=$(jq -r '.server.country' "${file}")
serverlocation=$(jq -r '.server.location' "${file}")
serverhost=$(jq -r '.server.host' "${file}")
timestamp=$(jq -r '.timestamp' "${file}")

echo "$(date -Iseconds) speedtest results"

echo "$(date -Iseconds) download = ${download} Mbps"
echo "$(date -Iseconds) upload =  ${upload} Mbps"
echo "$(date -Iseconds) ping =  ${ping} ms"
echo "$(date -Iseconds) jitter = ${jitter} ms"

echo "$(date -Iseconds) sending results to ${MQTT_HOST} as clientID ${MQTT_ID} using user ${MQTT_USER}"

mqtt_pub() {
  /usr/bin/mosquitto_pub -h "${MQTT_HOST}" -p "${MQTT_PORT}" -r -i "${MQTT_ID}" \
    "${MQTT_OPTIONS[@]}" -u "${MQTT_USER}" -P "${MQTT_PASS}" "$@"
}

mqtt_pub -t "${DISCOVERY_PREFIX}/sensor/speedtest-go-download/config" -m "{\"name\":\"Speedtest Go - Download\", \"state_topic\":\"${MQTT_TOPIC}/test\", \"value_template\":\"{{ value_json.download }}\", \"json_attributes_topic\": \"${MQTT_TOPIC}/test\", \"unit_of_measurement\":\"Mbps\", \"icon\":\"mdi:speedometer\", \"unique_id\":\"speedtest_go_download\"}"
mqtt_pub -t "${DISCOVERY_PREFIX}/sensor/speedtest-go-upload/config" -m "{\"name\":\"Speedtest Go - Upload\", \"state_topic\":\"${MQTT_TOPIC}/test\", \"value_template\":\"{{ value_json.upload }}\", \"json_attributes_topic\": \"${MQTT_TOPIC}/test\", \"unit_of_measurement\":\"Mbps\", \"icon\":\"mdi:speedometer\", \"unique_id\":\"speedtest_go_upload\"}"
mqtt_pub -t "${DISCOVERY_PREFIX}/sensor/speedtest-go-ping/config" -m "{\"name\":\"Speedtest Go - Ping\", \"state_topic\":\"${MQTT_TOPIC}/test\", \"value_template\":\"{{ value_json.ping }}\", \"json_attributes_topic\": \"${MQTT_TOPIC}/test\", \"unit_of_measurement\":\"ms\", \"icon\":\"mdi:access-point\", \"unique_id\":\"speedtest_go_ping\"}"
mqtt_pub -t "${DISCOVERY_PREFIX}/sensor/speedtest-go-jitter/config" -m "{\"name\":\"Speedtest Go - Jitter\", \"state_topic\":\"${MQTT_TOPIC}/test\", \"value_template\":\"{{ value_json.jitter }}\", \"json_attributes_topic\": \"${MQTT_TOPIC}/test\", \"unit_of_measurement\":\"ms\", \"icon\":\"mdi:access-point-remove\", \"unique_id\":\"speedtest_go_jitter\"}"
mqtt_pub -t "${DISCOVERY_PREFIX}/sensor/speedtest-go-packet-loss/config" -m "{\"name\":\"Speedtest Go - Packet loss\", \"state_topic\":\"${MQTT_TOPIC}/test\", \"value_template\":\"{{ value_json.packetloss }}\", \"json_attributes_topic\": \"${MQTT_TOPIC}/test\", \"unit_of_measurement\":\"%\", \"icon\":\"mdi:lan-disconnect\", \"unique_id\":\"speedtest_go_packet_loss\"}"

mqtt_pub -t "${MQTT_TOPIC}/test" -m "{\"download\":${download}, \"upload\":${upload}, \"ping\":${ping}, \"jitter\":${jitter}, \"packetloss\":${packetloss}, \"serverid\":${serverid}, \"servername\":\"${servername}\", \"servercountry\":\"${servercountry}\", \"serverlocation\":\"${serverlocation}\", \"serverhost\":\"${serverhost}\", \"timestamp\":\"${timestamp}\"}"

mqtt_pub -t "${MQTT_TOPIC}/download" -m "${download}"
mqtt_pub -t "${MQTT_TOPIC}/downraw" -m "${downraw}"
mqtt_pub -t "${MQTT_TOPIC}/upload" -m "${upload}"
mqtt_pub -t "${MQTT_TOPIC}/upraw" -m "${upraw}"
mqtt_pub -t "${MQTT_TOPIC}/ping" -m "${ping}"
mqtt_pub -t "${MQTT_TOPIC}/jitter" -m "${jitter}"
mqtt_pub -t "${MQTT_TOPIC}/packetloss" -m "${packetloss}"

mqtt_pub -t "${MQTT_TOPIC}/server/id" -m "${serverid}"
mqtt_pub -t "${MQTT_TOPIC}/server/name" -m "${servername}"
mqtt_pub -t "${MQTT_TOPIC}/server/location" -m "${serverlocation}"
mqtt_pub -t "${MQTT_TOPIC}/server/host" -m "${serverhost}"
mqtt_pub -t "${MQTT_TOPIC}/server/country" -m "${servercountry}"

mqtt_pub -t "${MQTT_TOPIC}/timestamp" -m "${timestamp}"
