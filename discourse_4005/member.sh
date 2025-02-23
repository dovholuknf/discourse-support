export ZITI_CTRL_NAME="$1"
. /init/common.env

/init/configure.sh $ZITI_CTRL_NAME
cat "$ZITI_PKI/$ZITI_INTERMEDIATE_NAME/certs/$ZITI_INTERMEDIATE_NAME.cert" >> "$ZITI_PKI_CTRL_CA"

function _wait_for_controller {
  local advertised_host_port="${ZITI_HOSTNAME}:${ZITI_CTRL_EDGE_ADVERTISED_PORT}"
  while [[ "$(curl -w "%{http_code}" -m 1 -s -k -o /dev/null https://"${advertised_host_port}"/edge/client/v1/version)" != "200" ]]; do
    echo "waiting for https://${advertised_host_port}"
    sleep 3
  done

  for i in {15..1}
  do
    echo "initializing the cluster. waiting $i seconds."
    sleep 1
  done
  ziti agent cluster add tls:controller1.docker.ziti:8440
}

_wait_for_controller &

ziti controller run ${ZITI_HOME}/${ZITI_HOSTNAME}.yaml