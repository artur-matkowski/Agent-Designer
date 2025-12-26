#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0")

List local agent directories under "$ROOT_DIR" and show whether they are
currently deployed in the global opencode configuration directory.

Environment:
  OPENCODE_GLOBAL_DIR  Path to global opencode agents directory
                      (default: $HOME/.config/opencode/agent)
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

ensure_global_dir

mapfile -t agents < <(list_agent_dirs)

if [[ ${#agents[@]} -eq 0 ]]; then
  echo "No agent directories found under $ROOT_DIR" >&2
  exit 0
fi

echo "Local agents (root: $ROOT_DIR) vs global: $OPENCODE_GLOBAL_DIR"
echo

for agent in "${agents[@]}"; do
  agent_status "$agent"
done
