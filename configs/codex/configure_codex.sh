#!/usr/bin/env bash
set -euo pipefail

ARS_CACHE_DIR="${HOME}/.codex/plugins/cache/academic-research-skills"

if [ ! -d "${ARS_CACHE_DIR}" ]; then
  exit 0
fi

find "${ARS_CACHE_DIR}" -type f -path '*/hooks/hooks.json' -print0 |
  while IFS= read -r -d '' hook_file; do
    python3 - "${hook_file}" <<'PY'
import json
import os
from pathlib import Path
import sys
import tempfile

path = Path(sys.argv[1])
data = json.loads(path.read_text())
hooks = data.get("hooks", {})

if "SessionStart" not in hooks:
    raise SystemExit(0)

del hooks["SessionStart"]

fd, temporary_path = tempfile.mkstemp(
    dir=path.parent,
    prefix=f".{path.name}.",
    text=True,
)
try:
    with os.fdopen(fd, "w") as temporary_file:
        json.dump(data, temporary_file, indent=2)
        temporary_file.write("\n")
    os.replace(temporary_path, path)
finally:
    if os.path.exists(temporary_path):
        os.unlink(temporary_path)
PY
  done
