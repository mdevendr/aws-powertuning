
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
rm -f package.zip
zip -r package.zip app.py requirements.txt >/dev/null
echo "Created package.zip"
