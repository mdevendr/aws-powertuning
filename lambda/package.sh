#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

rm -f package.zip
python - << 'EOF'
import zipfile
with zipfile.ZipFile("package.zip", "w", zipfile.ZIP_DEFLATED) as z:
    z.write("app.py")
EOF

echo "✅ Lambda packaged: lambda/package.zip"
