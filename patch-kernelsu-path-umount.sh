#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo " Patching KernelSU path_umount issue"
echo "========================================"

PATCHED=0

KSU_FILES=(
  "drivers/kernelsu/feature/kernel_umount.c"
  "drivers/kernelsu/kernel_umount.c"
  "KernelSU-Next/kernel/kernel_umount.c"
  "kernel/kernel_umount.c"
)

for file in "${KSU_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    continue
  fi

  if ! grep -q "path_umount" "$file"; then
    echo "No path_umount usage found in: $file"
    continue
  fi

  echo "Found path_umount usage in: $file"
  echo "Creating backup: ${file}.bak"
  cp -f "$file" "${file}.bak"

  python3 - "$file" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

original = text

# Remove/disable extern declaration for path_umount to avoid unresolved symbol.
text = re.sub(
    r'extern\s+int\s+path_umount\s*\(\s*struct\s+path\s*\*\s*path\s*,\s*int\s+flags\s*\)\s*;',
    '/* path_umount is not available on this kernel tree; KernelSU kernel_umount feature is disabled by CI patch. */',
    text
)

# Replace direct path_umount call with no-op success.
# This keeps KernelSU building while disabling only the problematic kernel_umount action.
text = re.sub(
    r'int\s+err\s*=\s*path_umount\s*\(\s*path\s*,\s*flags\s*\)\s*;',
    'int err = 0;\n\tpr_info_once("KernelSU: kernel_umount disabled on this kernel because path_umount is unavailable\\n");',
    text
)

# Some variants may have spacing/newline differences.
text = re.sub(
    r'int\s+err\s*=\s*path_umount\s*\(\s*&path\s*,\s*flags\s*\)\s*;',
    'int err = 0;\n\tpr_info_once("KernelSU: kernel_umount disabled on this kernel because path_umount is unavailable\\n");',
    text
)

if text == original:
    print(f"WARN: Could not automatically patch {path}. File format may be different.")
    sys.exit(2)

path.write_text(text)
print(f"Patched successfully: {path}")
PY

  echo "Patch result preview:"
  grep -n "path_umount\|kernel_umount disabled\|int err = 0" "$file" || true

  PATCHED=1
done

if [ "$PATCHED" -eq 0 ]; then
  echo "No KernelSU kernel_umount.c file with path_umount was patched."
  echo "This is okay if KernelSU version no longer uses path_umount."
else
  echo "KernelSU path_umount compatibility patch applied."
fi