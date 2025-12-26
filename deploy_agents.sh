#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0") [AGENT_DIR ...]

Deploy one or more agent directories into the global opencode configuration
from this project. If no AGENT_DIR is provided, all agent directories under
"$ROOT_DIR" (excluding ignored ones) are deployed.

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

# If arguments are given, they are treated as agent directory names.
# Otherwise, deploy all agent directories.

mapfile -t agents < <(list_agent_dirs "$@")

if [[ ${#agents[@]} -eq 0 ]]; then
  err "No agent directories found to deploy."
fi

for agent in "${agents[@]}"; do
  deploy_agent_dir "$agent"
  log "Done: $agent"
  echo
done

log "Deployment complete. Global dir: $OPENCODE_GLOBAL_DIR"
