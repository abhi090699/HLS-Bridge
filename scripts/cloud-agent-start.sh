#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default project root for this repository layout.
export CURRENT_PROJECT_PATH="${CURRENT_PROJECT_PATH:-$REPO_ROOT}"

# Persist useful defaults for interactive shells in this environment.
PROFILE_SNIPPET="$HOME/.hls_bridge_env.sh"
cat >"$PROFILE_SNIPPET" <<EOF
export CURRENT_PROJECT_PATH="${CURRENT_PROJECT_PATH}"
EOF

for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  if [[ -f "$rc" ]] && ! grep -q "hls_bridge_env.sh" "$rc" 2>/dev/null; then
    echo "[[ -f \"$PROFILE_SNIPPET\" ]] && source \"$PROFILE_SNIPPET\"" >>"$rc"
  fi
done

if command -v xrun >/dev/null 2>&1 && command -v xmroot >/dev/null 2>&1; then
  if [[ -z "${DENALI:-}" ]]; then
    echo "[start] Cadence Xcelium is available, but DENALI is not set." >&2
    echo "[start] Export DENALI to the Denali VIP installation path before running 'make run'." >&2
  else
    echo "[start] Cadence simulation toolchain detected (xrun + DENALI)."
  fi
else
  echo "[start] Open-source RTL smoke tests are ready via 'make -C sim smoke'."
  echo "[start] Full UVM simulation requires Cadence Xcelium and Denali VIP (see README.md)."
fi

echo "[start] Startup complete."
