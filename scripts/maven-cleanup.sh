#!/bin/bash
# Remove built JARs (target/) and generated application.properties so you can
# rebuild and regenerate from scratch. Use after changing config to verify.
#
# After running:
#   1. Regenerate application.properties: ./generate-properties.sh -all
#      (or ./replace-tokens.sh dev if you use that flow)
#   2. Build: ./scripts/build.sh [service] or mvn clean install in each service
#
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Cleaning Maven targets and generated application.properties..."
echo ""

# 1. Remove target/ (JARs and build artifacts) in each Java service
for dir in ts-*-service ts-common; do
  if [ ! -d "$dir" ]; then continue; fi
  if [ -f "$dir/pom.xml" ]; then
    if [ -d "$dir/target" ]; then
      echo "  Removing $dir/target/"
      rm -rf "$dir/target"
    fi
  fi
done

# 2. Remove JARs in jar/ (deployed/copied JARs)
if [ -d "jar" ]; then
  for j in jar/*.jar; do
    if [ -f "$j" ]; then
      echo "  Removing $j"
      rm -f "$j"
    fi
  done
fi

# 3. Remove generated application.properties (so they are regenerated from .ini)
count=0
while IFS= read -r -d '' f; do
  echo "  Removing $f"
  rm -f "$f"
  count=$((count + 1))
done < <(find ts-*-service -path '*/src/main/resources/application.properties' -type f -print0 2>/dev/null)

echo ""
echo -e "${GREEN}Done.${NC}"
echo "  - Maven target/ dirs removed (JARs cleared)"
echo "  - jar/*.jar removed (if any)"
echo "  - $count application.properties removed (generated files)"
echo ""
echo "Next: regenerate config and build"
echo "  ./generate-properties.sh -all    # from project root"
echo "  ./scripts/build.sh              # or build specific service"
