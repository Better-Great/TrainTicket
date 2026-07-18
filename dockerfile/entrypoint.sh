#!/bin/sh
# Shared entrypoint for all ts-*-service Java containers.
# Lean defaults target packing many services on ~8GiB hosts.
# Override with JAVA_OPTS in compose/.env (e.g. gateway: -Xmx192m -Xms64m).
set -e

SERVICE_NAME="${JAR_NAME%.jar}"
PROP_FILE="${EXTERNAL_CONFIG_DIR}/${ENVIRONMENT}.application.ini"

# Compact heap + SerialGC (lower native overhead than G1 on tiny heaps).
# Metaspace ceiling is sized for Spring Boot 3 / Jakarta EE (bigger classloading
# footprint than the old Boot 2.3 baseline this was first tuned for) — 96m OOM'd
# reliably on every service post-migration, 224m has headroom.
# Sentinel defaults to /app/logs/csp which breaks when the logs volume is root-owned.
: "${JAVA_OPTS:=-Xms32m -Xmx128m -Xss256k -XX:MetaspaceSize=80m -XX:MaxMetaspaceSize=160m -XX:+UseSerialGC -XX:+ExitOnOutOfMemoryError -Dcsp.sentinel.log.dir=/tmp/csp}"

if [ ! -f "$PROP_FILE" ]; then
    echo "Error: No env config at $PROP_FILE"
    ls -la "${EXTERNAL_CONFIG_DIR}/" 2>/dev/null || true
    exit 1
fi

mkdir -p "${PROJECT_ROOT}/properties" "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources"
cp "$PROP_FILE" "${PROJECT_ROOT}/properties/${ENVIRONMENT}.application.ini"
cp "${TEMPLATE_DIR}/application.properties.ini" "${PROJECT_ROOT}/${SERVICE_NAME}/"

# Configuration replacement is a one-shot short-lived JVM. The variable name
# deliberately avoids "TOKEN": this is a jar filename, not a credential.
java -Xms16m -Xmx64m -jar "${JAR_DIR}/${CONFIG_REPLACER_JAR_NAME}" "${ENVIRONMENT}" "${PROJECT_ROOT}"

if [ ! -f "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources/application.properties" ]; then
    echo "Error: Token replacement failed"
    exit 1
fi

cp "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources/application.properties" \
    "${CONFIG_DIR}/application-external.properties"
chmod 600 "${CONFIG_DIR}/application-external.properties"

# Use additional-location so classpath application.yml (e.g. gateway routes) is kept.
# spring.config.location would replace defaults and drop in-jar route definitions.
# shellcheck disable=SC2086
exec java ${JAVA_OPTS} -jar "${JAR_DIR}/${JAR_NAME}" \
    --spring.config.additional-location=file:${CONFIG_DIR}/application-external.properties \
    --server.port="${PORT}" \
    --logging.file.name="${LOGS_DIR}/${SERVICE_NAME}.log" \
    --logging.file.max-size=10MB --logging.file.max-history=5
