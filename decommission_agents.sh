#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0") [AGENT_DIR ...]

Decommission (remove) one or more deployed agent configurations from the
global opencode configuration directory, based on the local agent
subdirectories under "$ROOT_DIR".

If no AGENT_DIR is provided, all agent directories under "$ROOT_DIR"
(excluding ignored ones) are decommissioned.

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

mapfile -t agents < <(list_agent_dirs "$@")

if [[ ${#agents[@]} -eq 0 ]]; then
  err "No agent directories found to decommission."
fi

for agent in "${agents[@]}"; do
  decommission_agent_dir "$agent"
  log "Done: $agent"
  echo
done

log "Decommission complete. Global dir: $OPENCODE_GLOBAL_DIR"
