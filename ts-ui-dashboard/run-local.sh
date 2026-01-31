#!/bin/bash
# Serve ts-ui-dashboard static files locally on port 8080
# For /api/v1/ proxy to gateway, run via Docker or use nginx
cd "$(dirname "$0")"
echo "Starting ts-ui-dashboard at http://localhost:8080"
echo "Static files only - /api/v1/ requires gateway (use Docker for full stack)"
python3 -m http.server 8080 --directory static
