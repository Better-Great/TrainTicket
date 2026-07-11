#!/bin/sh
# Shared entrypoint for all ts-*-service Java containers.
# Derives the service name from JAR_NAME so one script covers every service —
# see gen_dockerfiles.sh, which previously baked a copy of this per service via
# a chained `echo >> /entrypoint.sh` block.
set -e

SERVICE_NAME="${JAR_NAME%.jar}"
PROP_FILE="${EXTERNAL_CONFIG_DIR}/${ENVIRONMENT}.application.ini"

if [ ! -f "$PROP_FILE" ]; then
    echo "Error: No env config at $PROP_FILE"
    ls -la "${EXTERNAL_CONFIG_DIR}/" 2>/dev/null || true
    exit 1
fi

mkdir -p "${PROJECT_ROOT}/properties" "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources"
cp "$PROP_FILE" "${PROJECT_ROOT}/properties/${ENVIRONMENT}.application.ini"
cp "${TEMPLATE_DIR}/application.properties.ini" "${PROJECT_ROOT}/${SERVICE_NAME}/"

java -jar "${JAR_DIR}/${TOKEN_JAR_NAME}" "${ENVIRONMENT}" "${PROJECT_ROOT}"

if [ ! -f "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources/application.properties" ]; then
    echo "Error: Token replacement failed"
    exit 1
fi

cp "${PROJECT_ROOT}/${SERVICE_NAME}/src/main/resources/application.properties" \
    "${CONFIG_DIR}/application-external.properties"
chmod 600 "${CONFIG_DIR}/application-external.properties"

exec java ${JAVA_OPTS:--Xmx256m -Xms128m} -jar "${JAR_DIR}/${JAR_NAME}" \
    --spring.config.location=file:${CONFIG_DIR}/application-external.properties \
    --server.port="${PORT}" \
    --logging.file.name="${LOGS_DIR}/${SERVICE_NAME}.log" \
    --logging.file.max-size=10MB --logging.file.max-history=5
