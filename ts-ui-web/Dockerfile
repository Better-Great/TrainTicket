# Local/package build context (docker compose build: ts-ui-web).
FROM oven/bun:1.3.14@sha256:e10577f0db68676a7024391c6e5cb4b879ebd17188ab750cf10024a6d700e5c4 AS spa
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY . ./
ENV VITE_USE_MOCK=false
# Type-checking (vue-tsc) runs in CI (`bun run check`) — the image build only
# needs vite's transpile+bundle, which doesn't invoke vue-tsc's project-reference
# build (this kept failing container-only on .vue module resolution).
RUN bun run build:image

FROM alpine:3.23@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40
COPY edge/nginx.conf /etc/nginx/nginx.conf
COPY --from=spa /app/dist/ /usr/share/nginx/html/
COPY legacy/ /usr/share/nginx/html/legacy/
RUN apk upgrade --no-cache \
    && apk add --no-cache nginx=1.28.3-r5 \
    && mkdir -p /var/cache/nginx \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --retries=10 \
    CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1
CMD ["nginx", "-g", "daemon off;"]
