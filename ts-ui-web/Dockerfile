# Local/package build context (docker compose build: ts-ui-web).
FROM oven/bun:1.3.14 AS spa
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY . ./
ENV VITE_USE_MOCK=false
# Type-checking (vue-tsc) runs in CI (`bun run check`) — the image build only
# needs vite's transpile+bundle, which doesn't invoke vue-tsc's project-reference
# build (this kept failing container-only on .vue module resolution).
RUN bun run build:image

FROM nginx:1.26-alpine
COPY edge/nginx.conf /etc/nginx/nginx.conf
COPY --from=spa /app/dist/ /usr/share/nginx/html/
COPY legacy/ /usr/share/nginx/html/legacy/
RUN mkdir -p /var/cache/nginx \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --retries=10 \
    CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1
