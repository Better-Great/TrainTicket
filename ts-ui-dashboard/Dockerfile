# ts-ui-dashboard: nginx serves static/; proxies /api/v1/ to ts-gateway-service.
# Build (this directory as context):
#   docker build -t ts-ui-dashboard .
# Local static only (no API proxy): ./run-local.sh
#
# Homepage: static/index.html → http://<host>:8080/ (admin UI).
# Client UI entry: static/client_login.html

FROM nginx:1.26-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY static/ /usr/share/nginx/html/

EXPOSE 8080
