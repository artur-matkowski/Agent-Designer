#!/usr/bin/env bash
set -euo pipefail

# Shared configuration and helper functions for agent deployment

# Root of this project (directory where this script lives)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global opencode configuration directory.
# You can override this per-shell by exporting OPENCODE_GLOBAL_DIR.
OPENCODE_GLOBAL_DIR="${OPENCODE_GLOBAL_DIR:-$HOME/.config/opencode/agents}"

# Directories that should never be treated as agent directories
IGNORED_AGENT_DIRS=(".git" ".github" "node_modules" "venv" "__pycache__")

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

err() {
  log "ERROR: $*"
  exit 1
}

ensure_global_dir() {
  if [[ ! -d "$OPENCODE_GLOBAL_DIR" ]]; then
    log "Creating global opencode config directory: $OPENCODE_GLOBAL_DIR"
    mkdir -p "$OPENCODE_GLOBAL_DIR"
  fi
}

is_ignored_agent_dir() {
  local name="$1"
  for d in "${IGNORED_AGENT_DIRS[@]}"; do
    if [[ "$name" == "$d" ]]; then
      return 0
    fi
  done
  return 1
}

# List agent directories under ROOT_DIR.
# If arguments are provided, only those names are returned (if they exist).
list_agent_dirs() {
  local requested=("$@")
  local dir

  if [[ ${#requested[@]} -eq 0 ]]; then
    # All subdirectories, except ignored
    for dir in "$ROOT_DIR"/*/; do
      [[ -d "$dir" ]] || continue
      dir="${dir%/}"
      local name="${dir##*/}"
      if is_ignored_agent_dir "$name"; then
        continue
      fi
      printf '%s\n' "$name"
    done
  else
    # Only requested names
    for name in "${requested[@]}"; do
      dir="$ROOT_DIR/$name"
      if [[ ! -d "$dir" ]]; then
        err "Agent directory not found: $name ($dir)"
      fi
      if is_ignored_agent_dir "$name"; then
        err "Requested directory '$name' is in ignored list, refusing to treat as agent directory."
      fi
      printf '%s\n' "$name"
    done
  fi
}

# Deploy a single agent directory (by name).
# Copies all files under $ROOT_DIR/<agent_name> into $OPENCODE_GLOBAL_DIR,
# preserving relative paths beneath that directory.

deploy_agent_dir() {
  local agent_name="$1"
  local src_dir="$ROOT_DIR/$agent_name"
  local dst_root="$OPENCODE_GLOBAL_DIR"

  [[ -d "$src_dir" ]] || err "deploy_agent_dir: source directory does not exist: $src_dir"

  log "Deploying agent directory '$agent_name' to '$dst_root'"

  # Find all files under the agent directory and copy them preserving relative paths
  while IFS= read -r -d '' src_file; do
    local rel_path="${src_file#$src_dir/}"
    local dst_file="$dst_root/$rel_path"
    local dst_dir
    dst_dir="$(dirname "$dst_file")"
    mkdir -p "$dst_dir"
    cp "$src_file" "$dst_file"
    log "  -> $rel_path"
  done < <(find "$src_dir" -type f -print0)
}

# Decommission a single agent directory (by name).
# For every file under $ROOT_DIR/<agent_name>, remove the corresponding
# file under $OPENCODE_GLOBAL_DIR (same relative path).

decommission_agent_dir() {
  local agent_name="$1"
  local src_dir="$ROOT_DIR/$agent_name"
  local dst_root="$OPENCODE_GLOBAL_DIR"

  [[ -d "$src_dir" ]] || err "decommission_agent_dir: source directory does not exist: $src_dir"

  log "Decommissioning agent directory '$agent_name' from '$dst_root'"

  while IFS= read -r -d '' src_file; do
    local rel_path="${src_file#$src_dir/}"
    local dst_file="$dst_root/$rel_path"
    if [[ -f "$dst_file" ]]; then
      rm "$dst_file"
      log "  removed $rel_path"
      # Try to remove now-empty parent directories up to dst_root
      local parent_dir="$(dirname "$dst_file")"
      while [[ "$parent_dir" != "$dst_root" && "$parent_dir" != / ]]; do
        rmdir "$parent_dir" 2>/dev/null || break
        parent_dir="$(dirname "$parent_dir")"
      done
    else
      log "  (missing) $rel_path"
    fi
  done < <(find "$src_dir" -type f -print0)
}

# Show basic information about an agent directory: name and number of files,
# and whether at least one file is currently deployed.

agent_status() {
  local agent_name="$1"
  local src_dir="$ROOT_DIR/$agent_name"
  local dst_root="$OPENCODE_GLOBAL_DIR"

  local total_files=0
  local deployed_files=0

  while IFS= read -r -d '' src_file; do
    total_files=$((total_files + 1))
    local rel_path="${src_file#$src_dir/}"
    local dst_file="$dst_root/$rel_path"
    if [[ -f "$dst_file" ]]; then
      deployed_files=$((deployed_files + 1))
    fi
  done < <(find "$src_dir" -type f -print0)

  local status
  if (( deployed_files == 0 )); then
    status="not deployed"
  elif (( deployed_files == total_files )); then
    status="fully deployed"
  else
    status="partially deployed"
  fi

  printf '%s: %s (%d/%d files deployed)\n' "$agent_name" "$status" "$deployed_files" "$total_files"
}
