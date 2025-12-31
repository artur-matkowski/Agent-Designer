#!/bin/bash

# deploy.sh - Deploy content of a directory to global directory
# Usage:
#   ./deploy.sh <directory_name>
#   ./deploy.sh all   # deploy all agent directories

set -e

# Load common config early to get GLOBAL_DEPLOY_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-config.conf" ]; then
    source "$SCRIPT_DIR/common-config.conf"
else
    echo "Error: common-config.conf not found" >&2
    exit 1
fi

# Create global deploy directory if it doesn't exist
mkdir -p "$GLOBAL_DEPLOY_DIR"

# If no parameter, show usage
if [ $# -eq 0 ]; then
    echo "Error: Directory name parameter is required" >&2
    echo "Usage: $0 <directory_name|all>" >&2
    exit 1
fi

MODE="$1"

# Function to deploy a single directory
deploy_dir() {
    local dir_name="$1"

    if [ -z "$dir_name" ]; then
        echo "Error: deploy_dir called without directory name" >&2
        return 1
    fi

    local source_dir="$dir_name"

    # Skip non-directories
    if [ ! -d "$source_dir" ]; then
        echo "Skipping '$source_dir' (not a directory)" >&2
        return 0
    fi

    echo "Deploying files from '$source_dir' to '$GLOBAL_DEPLOY_DIR'..."
    cp -r "$source_dir"/* "$GLOBAL_DEPLOY_DIR/" 2>/dev/null || true
}

if [ "$MODE" = "all" ]; then
    echo "Deploying all agent directories..."

    # Loop over immediate subdirectories and deploy each
    for d in "$SCRIPT_DIR"/*/; do
        # Normalize name (strip trailing slash and path)
        dir_name="$(basename "${d%/}")"

        # Skip hidden directories and any non-agent infrastructure dirs if needed
        case "$dir_name" in
            .git|.opencode) continue ;;
        esac

        deploy_dir "$dir_name"
    done

    echo "Deployment of all agents completed successfully"
    exit 0
fi

# Single-directory mode (original behavior)
DIR_NAME="$MODE"
SOURCE_DIR="$DIR_NAME"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist" >&2
    exit 1
fi

# Copy files from source directory to global directory
echo "Deploying files from '$SOURCE_DIR' to '$GLOBAL_DEPLOY_DIR'..."
cp -r "$SOURCE_DIR"/* "$GLOBAL_DEPLOY_DIR/"

echo "Deployment completed successfully"