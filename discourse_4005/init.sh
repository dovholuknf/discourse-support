export ZITI_CTRL_NAME="controller1"
. /init/common.env

ziti pki create ca \
  --trust-domain="docker.ziti" \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_ROOT_CA_NAME}" \
  --ca-file "${ZITI_ROOT_CA_NAME}"

/init/configure.sh $ZITI_CTRL_NAME

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
  ziti agent controller init "admin" "${ZITI_PWD}" "${ZITI_CTRL_NAME}"
}

_wait_for_controller &

ziti controller run ${ZITI_HOME}/${ZITI_HOSTNAME}.yaml