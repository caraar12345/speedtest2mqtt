#!/bin/bash

CONFIG_PATH="/data/options.json"
export MQTT_HOST="$(jq --raw-output '.mqtt_host // empty' $CONFIG_PATH)"
export MQTT_PORT="$(jq --raw-output '.mqtt_port // empty' $CONFIG_PATH)"
export MQTT_ID="$(jq --raw-output '.mqtt_id // empty' $CONFIG_PATH)"
export MQTT_TOPIC="$(jq --raw-output '.mqtt_topic // empty' $CONFIG_PATH)"
export MQTT_OPTIONS="$(jq --raw-output '.mqtt_options // empty' $CONFIG_PATH)"
export MQTT_USER="$(jq --raw-output '.mqtt_username // empty' $CONFIG_PATH)"
export MQTT_PASS="$(jq --raw-output '.mqtt_password // empty' $CONFIG_PATH)"

file=~/ookla.json

echo "$(date -Iseconds) starting speedtest"

speedtest --accept-license --accept-gdpr -f json-pretty > ${file}

downraw=$(jq -r '.download.bandwidth' ${file})
download=$(printf %.2f\\n "$((downraw * 8))e-6")
upraw=$(jq -r '.upload.bandwidth' ${file})
upload=$(printf %.2f\\n "$((upraw * 8))e-6")
ping=$(jq -r '.ping.latency' ${file})
jitter=$(jq -r '.ping.jitter' ${file})
packetloss=$(jq -r '.packetLoss' ${file})
serverid=$(jq -r '.server.id' ${file})
servername=$(jq -r '.server.name' ${file})
servercountry=$(jq -r '.server.country' ${file})
serverlocation=$(jq -r '.server.location' ${file})
serverhost=$(jq -r '.server.host' ${file})
timestamp=$(jq -r '.timestamp' ${file})

echo "$(date -Iseconds) speedtest results"

echo "$(date -Iseconds) download = ${download} Mbps"
echo "$(date -Iseconds) upload =  ${upload} Mbps"
echo "$(date -Iseconds) ping =  ${ping} ms"
echo "$(date -Iseconds) jitter = ${jitter} ms"

echo "$(date -Iseconds) sending results to ${MQTT_HOST} as clientID ${MQTT_ID} with options ${MQTT_OPTIONS} using user ${MQTT_USER}"

/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/download -m "${download}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/downraw -m "${downraw}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/upload -m "${upload}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/upraw -m "${upraw}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/ping -m "${ping}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/jitter -m "${jitter}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/packetloss -m "${packetloss}"

/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/server/id -m "${serverid}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/server/name -m "${servername}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/server/location -m "${serverlocation}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/server/host -m "${serverhost}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/server/country -m "${servercountry}"

/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/timestamp -m "${timestamp}"
