#!/usr/bin/env bashio

CONFIG_PATH="/data/options.json"
export MQTT_HOST=$(bashio::services mqtt "host")
export MQTT_PORT=$(bashio::services mqtt "port")
export MQTT_USER=$(bashio::services mqtt "username")
export MQTT_PASS=$(bashio::services mqtt "password")

export MQTT_ID="speedtest-mqtt-hass"
export MQTT_TOPIC="$(jq --raw-output '.mqtt_topic // empty' $CONFIG_PATH)"
export MQTT_OPTIONS="$(jq --raw-output '.mqtt_options // empty' $CONFIG_PATH)"


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

/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/speedtest-go-download/config -m "{\"name\":\"Speedtest Go - Download\", \"state_topic\":\"homeassistant/sensor/speedtest/test\", \"value_template\":\"{{ value_json.download }}\", \"json_attributes_topic\": \"homeassistant/sensor/speedtest/test\", \"unit_of_measurement\":\"Mbps\", \"icon\":\"mdi:speedometer\", \"unique_id\":\"speedtest_go_download\"}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/speedtest-go-upload/config -m "{\"name\":\"Speedtest Go - Upload\", \"state_topic\":\"homeassistant/sensor/speedtest/test\", \"value_template\":\"{{ value_json.upload }}\", \"json_attributes_topic\": \"homeassistant/sensor/speedtest/test\", \"unit_of_measurement\":\"Mbps\", \"icon\":\"mdi:speedometer\", \"unique_id\":\"speedtest_go_upload\"}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/speedtest-go-ping/config -m "{\"name\":\"Speedtest Go - Ping\", \"state_topic\":\"homeassistant/sensor/speedtest/test\", \"value_template\":\"{{ value_json.ping }}\", \"json_attributes_topic\": \"homeassistant/sensor/speedtest/test\", \"unit_of_measurement\":\"ms\", \"icon\":\"mdi:access-point\", \"unique_id\":\"speedtest_go_ping\"}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/speedtest-go-jitter/config -m "{\"name\":\"Speedtest Go - Jitter\", \"state_topic\":\"homeassistant/sensor/speedtest/test\", \"value_template\":\"{{ value_json.jitter }}\", \"json_attributes_topic\": \"homeassistant/sensor/speedtest/test\", \"unit_of_measurement\":\"ms\", \"icon\":\"mdi:access-point-remove\", \"unique_id\":\"speedtest_go_jitter\"}"
/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/speedtest-go-packet-loss/config -m "{\"name\":\"Speedtest Go - Packet loss\", \"state_topic\":\"homeassistant/sensor/speedtest/test\", \"value_template\":\"{{ value_json.packetloss }}\", \"json_attributes_topic\": \"homeassistant/sensor/speedtest/test\", \"unit_of_measurement\":\"%\", \"icon\":\"mdi:lan-disconnect\", \"unique_id\":\"speedtest_go_packet_loss\"}"

/usr/bin/mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -r -i ${MQTT_ID} ${MQTT_OPTIONS} -u ${MQTT_USER} -P ${MQTT_PASS} -t ${MQTT_TOPIC}/test -m "{\"download\":${download}, \"upload\":${upload}, \"ping\":${ping}, \"jitter\":${jitter}, \"packetloss\":${packetloss}, \"serverid\":${serverid}, \"servername\":\"${servername}\", \"servercountry\":\"${servercountry}\", \"serverlocation\":\"${serverlocation}\", \"serverhost\":\"${serverhost}\", \"timestamp\":\"${timestamp}\"}"
## {\"download\":${download},\"upload\":${upload},\"ping\":${ping},\"jitter\":${jitter},\"packetloss\":${packetloss},\"serverid\":${serverid},\"servername\":\"${servername}\",\"servercountry\":\"${servercountry}\",\"serverlocation\":\"${serverlocation}\",\"serverhost\":\"${serverhost}\",\"timestamp\":\"${timestamp}\"}"

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
