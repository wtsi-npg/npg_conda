#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/bar" <<EOF
#!/bin/bash
echo bar
EOF

chmod +x "$PREFIX/bin/bar"
