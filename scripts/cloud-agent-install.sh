#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "[install] Ensuring open-source HDL tooling is available..."
for tool in make bc verilator iverilog python3; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "[install] Missing required tool: $tool" >&2
    exit 1
  fi
done

echo "[install] Running RTL smoke-test build..."
make -C sim smoke

echo "[install] Install complete."
