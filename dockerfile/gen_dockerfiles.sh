#!/bin/bash
# Generate Dockerfile.Ts.*.Service for each Java service (same structure as Dockerfile.Ts.Auth.Service).
# Run from repo root.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# service_name:default_port (from docker-compose or assumed)
SERVICES=(
  "ts-verification-code-service:15678"
  "ts-contacts-service:12347"
  "ts-order-service:12031"
  "ts-order-other-service:12032"
  "ts-config-service:15679"
  "ts-station-service:12345"
  "ts-train-service:14567"
  "ts-travel-service:12346"
  "ts-travel2-service:16346"
  "ts-preserve-service:14568"
  "ts-preserve-other-service:14569"
  "ts-basic-service:15680"
  "ts-price-service:16579"
  "ts-notification-service:17853"
  "ts-security-service:11188"
  "ts-inside-payment-service:18673"
  "ts-execute-service:12386"
  "ts-payment-service:19001"
  "ts-rebook-service:18886"
  "ts-cancel-service:18885"
  "ts-route-service:11178"
  "ts-assurance-service:18888"
  "ts-seat-service:18898"
  "ts-travel-plan-service:14322"
  "ts-route-plan-service:14578"
  "ts-food-service:18856"
  "ts-station-food-service:18857"
  "ts-consign-price-service:16110"
  "ts-consign-service:16111"
  "ts-admin-route-service:16113"
  "ts-admin-travel-service:16114"
  "ts-admin-user-service:16115"
  "ts-user-service:12342"
  "ts-delivery-service:16800"
  "ts-train-food-service:16801"
  "ts-gateway-service:16802"
  "ts-food-delivery-service:16803"
  "ts-wait-order-service:16804"
)

to_dockerfile_name() {
  local s="$1"
  s="${s#ts-}"
  s="${s%-service}"
  local out="Ts."
  while [[ "$s" == *-* ]]; do
    part="${s%%-*}"
    s="${s#*-}"
    out+="$(echo "$part" | sed 's/^\(.\)/\U\1/')."
  done
  out+="$(echo "$s" | sed 's/^\(.\)/\U\1/').Service"
  echo "$out"
}

for entry in "${SERVICES[@]}"; do
  name="${entry%%:*}"
  port="${entry##*:}"
  dfname="$(to_dockerfile_name "$name")"
  path="dockerfile/Dockerfile.${dfname}"
  [[ -f "$path" ]] && continue
  echo "Creating $path ..."
  cat > "$path" << DOCKERFILE
# Production-ready ${name}.
# Expects JARs in jar/: ${name}.jar, ts-token-replacement-service.jar
# Run: mount properties at /app/external-config, set ENVIRONMENT (docker|dev|prod).

FROM eclipse-temurin:17-jre-alpine

ENV JAR_NAME="${name}.jar" \\
    TOKEN_JAR_NAME="ts-token-replacement-service.jar" \\
    APP_HOME="/app" \\
    CONFIG_DIR="/app/config" \\
    TEMPLATE_DIR="/app/templates" \\
    JAR_DIR="/app/jar" \\
    LOGS_DIR="/app/logs" \\
    PROJECT_ROOT="/app/project" \\
    EXTERNAL_CONFIG_DIR="/app/external-config" \\
    ENVIRONMENT="\${ENVIRONMENT:-docker}" \\
    TZ="\${TZ:-UTC}" \\
    PORT="\${PORT:-${port}}"

RUN apk add --no-cache tzdata wget && \\
    adduser -D -h "\${APP_HOME}" -s /bin/sh train-ticket && \\
    mkdir -p "\${JAR_DIR}" "\${CONFIG_DIR}" "\${TEMPLATE_DIR}" "\${LOGS_DIR}" "\${EXTERNAL_CONFIG_DIR}" && \\
    chown -R train-ticket:train-ticket "\${APP_HOME}"

COPY --chown=train-ticket:train-ticket jar/${name}.jar jar/ts-token-replacement-service.jar \${JAR_DIR}/
COPY --chown=train-ticket:train-ticket dockerfile/templates/${name}/application.properties.ini \${TEMPLATE_DIR}/
RUN chmod 444 \${JAR_DIR}/*.jar \${TEMPLATE_DIR}/application.properties.ini

COPY dockerfile/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR \${CONFIG_DIR}
USER train-ticket
EXPOSE ${port}

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \\
    CMD wget -q -O /dev/null "http://127.0.0.1:\${PORT:-${port}}/actuator/health" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
DOCKERFILE
done
echo "Done."
