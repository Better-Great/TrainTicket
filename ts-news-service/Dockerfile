# Build: docker build -t ts-news-service:latest .
# Runtime: Alpine with busybox shell; static Go binary.

FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY main.go ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /news .

FROM alpine:3.20
RUN addgroup -S train-ticket && adduser -S -G train-ticket -u 1000 train-ticket
WORKDIR /
COPY --from=build /news /news
RUN chown train-ticket:train-ticket /news && chmod 0555 /news
USER train-ticket:train-ticket
ENV NEWS_SERVICE_PORT=${NEWS_SERVICE_PORT}
EXPOSE ${NEWS_SERVICE_PORT}
ENTRYPOINT ["/news"]
