#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/baz" <<EOF
#!/bin/bash
echo baz
EOF

chmod +x "$PREFIX/bin/baz"
