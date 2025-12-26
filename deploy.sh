#!/bin/bash

# deploy.sh - Deploy content of a directory to global directory
# Usage: ./deploy.sh <directory_name>

set -e

# Check if directory name parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: Directory name parameter is required"
    echo "Usage: $0 <directory_name>"
    exit 1
fi

DIR_NAME="$1"
SOURCE_DIR="$DIR_NAME"

# Load common config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-config.conf" ]; then
    source "$SCRIPT_DIR/common-config.conf"
else
    echo "Error: common-config.conf not found"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

# Create global deploy directory if it doesn't exist
mkdir -p "$GLOBAL_DEPLOY_DIR"

# Copy files from source directory to global directory
echo "Deploying files from '$SOURCE_DIR' to '$GLOBAL_DEPLOY_DIR'..."
cp -r "$SOURCE_DIR"/* "$GLOBAL_DEPLOY_DIR/"

echo "Deployment completed successfully"