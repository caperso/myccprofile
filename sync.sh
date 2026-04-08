#!/bin/bash
cd ~/.claude

# Check if there's a remote configured
if ! git remote get-url origin &>/dev/null; then
    echo "No remote configured. Skipping sync."
    exit 0
fi

# Add all changes
git add -A

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

# Commit with timestamp
git commit -m "Sync $(date '+%Y-%m-%d %H:%M:%S')"

# Push to remote
git push origin main