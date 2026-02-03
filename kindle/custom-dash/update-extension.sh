#!/bin/sh

#!/bin/sh

set -e

REPO_URL="https://github.com/mariannefeng/kindle-hax"
BASE_PATH="kindle/custom-dash"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Downloading files from $REPO_URL..."

curl -H 'Cache-Control: no-cache' -sL "https://raw.githubusercontent.com/mariannefeng/kindle-hax/main/kindle/custom-dash/config.xml" -o config.xml
curl -H 'Cache-Control: no-cache' -sL "https://raw.githubusercontent.com/mariannefeng/kindle-hax/main/kindle/custom-dash/menu.json" -o menu.json

mkdir -p bin

curl -H 'Cache-Control: no-cache' -sL "https://raw.githubusercontent.com/mariannefeng/kindle-hax/main/kindle/custom-dash/bin/start.sh" -o bin/start.sh
curl -H 'Cache-Control: no-cache' -sL "https://raw.githubusercontent.com/mariannefeng/kindle-hax/main/kindle/custom-dash/bin/stop.sh" -o bin/stop.sh

chmod +x bin/start.sh bin/stop.sh

echo "Files have been downloaded and replaced:"
echo " - config.xml"
echo " - menu.json"
echo " - bin/start.sh"
echo " - bin/stop.sh"


