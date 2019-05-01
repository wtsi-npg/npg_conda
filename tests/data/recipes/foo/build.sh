#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/foo" <<EOF
#!/bin/bash
echo foo
EOF

chmod +x "$PREFIX/bin/foo"
