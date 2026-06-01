ts-news-service (Go)

Dependencies
------------
None. MongoDB usage in older code is commented out; the handler returns static JSON.

Run locally
-----------
  ./run-local.sh

Or:

  export NEWS_SERVICE_PORT=12862   # optional; default 12862
  go run ./src/main

Build binary
------------
  go build -o news ./src/main

Smoke test
----------
  curl -s http://127.0.0.1:12862/
  curl -s "http://127.0.0.1:12862/test?cal=50"

Docker
------
  docker build -t ts-news-service:latest .

Port matches docker-compose (12862) and properties NewsServiceHost routing.
