export ZITI_CTRL_NAME="$1"

. /init/common.env
 
ziti pki create intermediate \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_ROOT_CA_NAME}" \
  --intermediate-name "${ZITI_INTERMEDIATE_NAME}" \
  --intermediate-file "${ZITI_INTERMEDIATE_NAME}" \
  --max-path-len "1"
  
ziti pki create intermediate \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_ROOT_CA_NAME}" \
  --intermediate-name "${ZITI_PKI_SIGNER_NAME}" \
  --intermediate-file "${ZITI_PKI_SIGNER_NAME}" \
  --max-path-len "1"

ziti pki create key \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_INTERMEDIATE_NAME}" \
  --key-file "${ZITI_CTRL_NAME}"

ziti pki create server \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_INTERMEDIATE_NAME}" \
  --key-file "${ZITI_CTRL_NAME}" \
  --server-file "${ZITI_CTRL_NAME}-server" \
  --server-name "${ZITI_CTRL_NAME}-server" \
  --spiffe-id "${ZITI_SPIFFE_ID}" \
  --dns "${ZITI_NETWORK_COMPONENTS_ADDRESSES}" \
  --ip "${ZITI_NETWORK_COMPONENTS_IPS}"

ziti pki create client \
  --pki-root="${ZITI_PKI}" \
  --ca-name "${ZITI_INTERMEDIATE_NAME}" \
  --key-file "${ZITI_CTRL_NAME}" \
  --spiffe-id "${ZITI_SPIFFE_ID}" \
  --client-file "${ZITI_CTRL_NAME}-client" \
  --client-name "${ZITI_CTRL_NAME}"

mkdir -p "${ZITI_HOME}"
mkdir -p "${ZITI_HOME}/db"

ziti create config controller --minCluster 1 > "${ZITI_HOME}/${ZITI_HOSTNAME}.yaml"

cat "${ZITI_PKI}/${ZITI_ROOT_CA_NAME}/certs/${ZITI_ROOT_CA_NAME}.cert" >> "${ZITI_PKI_CTRL_CA}"


