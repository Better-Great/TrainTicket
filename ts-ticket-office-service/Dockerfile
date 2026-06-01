# Build with this directory as context:
#   docker build -t ts-ticket-office-service .
# Optional at build: export TICKET_OFFICE_SERVICE_PORT so EXPOSE matches your -p mapping.
# Runtime (required): TICKET_OFFICE_MYSQL_* (see .env.example).
# HTTP port: set PORT, or TICKET_OFFICE_SERVICE_PORT (image sets PORT from it).

FROM node:18-alpine

ENV NODE_ENV=production

RUN addgroup -S train-ticket && adduser -S -G train-ticket -u 10001 train-ticket

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY app.js ./
COPY bin ./bin
COPY public ./public

RUN chown -R train-ticket:train-ticket /app
USER train-ticket:train-ticket

ARG TICKET_OFFICE_SERVICE_PORT
ENV TICKET_OFFICE_SERVICE_PORT=${TICKET_OFFICE_SERVICE_PORT}
ENV PORT=${TICKET_OFFICE_SERVICE_PORT}

EXPOSE ${TICKET_OFFICE_SERVICE_PORT}

CMD ["node", "bin/www"]
