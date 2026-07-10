# Local/package build context (docker compose build: ts-ui-web).
FROM oven/bun:1.3.14 AS spa
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY . ./
ENV VITE_USE_MOCK=false
RUN bun run build

FROM nginx:1.26-alpine
COPY edge/nginx.conf /etc/nginx/nginx.conf
COPY --from=spa /app/dist/ /usr/share/nginx/html/
COPY legacy/ /usr/share/nginx/html/legacy/
EXPOSE 8080
