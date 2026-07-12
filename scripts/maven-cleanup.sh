#!/bin/bash
# Wipe Maven targets, staged jar/, and generated application.properties so you
# can rebuild cleanly after config or dependency changes.
#
# Afterward:
#   ./scripts/build.sh all
#   ./scripts/deploy.sh all
#   docker compose -f docker-compose.build.yml build   # if you use containers
#
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
NC='\033[0m'

echo "Cleaning Maven targets and generated application.properties..."
echo ""

for dir in ts-*-service ts-common; do
  if [ ! -d "$dir" ]; then continue; fi
  if [ -f "$dir/pom.xml" ] && [ -d "$dir/target" ]; then
    echo "  Removing $dir/target/"
    rm -rf "$dir/target"
  fi
done

if [ -d "jar" ]; then
  for j in jar/*.jar; do
    if [ -f "$j" ]; then
      echo "  Removing $j"
      rm -f "$j"
    fi
  done
fi

count=0
while IFS= read -r -d '' f; do
  echo "  Removing $f"
  rm -f "$f"
  count=$((count + 1))
done < <(find ts-*-service -path '*/src/main/resources/application.properties' -type f -print0 2>/dev/null)

echo ""
echo -e "${GREEN}Done.${NC}"
echo "  - Maven target/ dirs removed"
echo "  - jar/*.jar removed (if any)"
echo "  - $count application.properties removed"
echo ""
echo "Next:"
echo "  ./scripts/build.sh all && ./scripts/deploy.sh all"
