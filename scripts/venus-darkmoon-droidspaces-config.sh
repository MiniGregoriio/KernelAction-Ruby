#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo " Creating venus Darkmoon Droidspaces config"
echo " Matching working Darkmoon-KSU-Next kernel"
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

# cgroups baseline for containers
CONFIG_CGROUPS=y
CONFIG_CGROUP_SCHED=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CPUSETS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_PIDS=y

# Match working Darkmoon kernel:
# uname -r = 5.4.288-Darkmoon-KSU-Next
CONFIG_LOCALVERSION="-Darkmoon-KSU-Next"
CONFIG_LOCALVERSION_AUTO=y
EOF

echo "Created config fragment:"
echo "$CONFIG_FILE"

echo ""
echo "Config fragment content:"
cat "$CONFIG_FILE"

echo ""
echo "Done."