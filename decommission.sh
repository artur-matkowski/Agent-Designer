#!/bin/bash

# decommission.sh - Remove deployed files from global directory
# Usage: ./decommission.sh <directory_name>

set -e

# Check if directory name parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: Directory name parameter is required"
    echo "Usage: $0 <directory_name>"
    exit 1
fi

DIR_NAME="$1"
LOCAL_DIR="$DIR_NAME"

# Load common config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-config.conf" ]; then
    source "$SCRIPT_DIR/common-config.conf"
else
    echo "Error: common-config.conf not found"
    exit 1
fi

# Check if local directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Error: Local directory '$LOCAL_DIR' does not exist"
    exit 1
fi

# Check if global deploy directory exists
if [ ! -d "$GLOBAL_DEPLOY_DIR" ]; then
    echo "Error: Global deploy directory '$GLOBAL_DEPLOY_DIR' does not exist"
    exit 1
fi

# List and remember files in local directory
echo "Scanning local directory '$LOCAL_DIR' for files to remove..."
LOCAL_FILES=()
while IFS= read -r -d '' file; do
    # Get relative filename
    rel_file="${file#$LOCAL_DIR/}"
    LOCAL_FILES+=("$rel_file")
done < <(find "$LOCAL_DIR" -type f -print0)

if [ ${#LOCAL_FILES[@]} -eq 0 ]; then
    echo "No files found in local directory"
    exit 0
fi

echo "Found ${#LOCAL_FILES[@]} files in local directory"

# Remove matching files from global directory
REMOVED_COUNT=0
for local_file in "${LOCAL_FILES[@]}"; do
    global_file="$GLOBAL_DEPLOY_DIR/$local_file"
    if [ -f "$global_file" ]; then
        echo "Removing: $global_file"
        rm "$global_file"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    else
        echo "Not found in global directory: $local_file"
    fi
done

echo "Decommission completed. Removed $REMOVED_COUNT files from global directory"