#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo " Creating venus SukiSU Droidspaces config"
echo " Matching working LK kernel localversion"
echo "========================================"

CONFIG_DIR="arch/arm64/configs/vendor"
CONFIG_FILE="$CONFIG_DIR/droidspaces_venus.config"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<'EOF'
# Droidspaces container support
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y

# IPC dependencies
CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y

# Droidspaces /dev support
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y

# tmpfs support
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y

# Match the booting SukiSU/SUSFS kernel:
# uname -r from working boot image: 5.4.302-LK+
CONFIG_LOCALVERSION="-LK"
# CONFIG_LOCALVERSION_AUTO is not set
EOF

# The booting kernel release is 5.4.302-LK+
# CONFIG_LOCALVERSION contributes "-LK"
# .scmversion contributes "+"
echo "+" > .scmversion

echo "Created config fragment:"
echo "$CONFIG_FILE"

echo ""
echo "Config fragment content:"
cat "$CONFIG_FILE"

echo ""
echo ".scmversion content:"
cat .scmversion

echo ""
echo "Done."