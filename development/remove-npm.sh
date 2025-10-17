#!/bin/bash
# remove-npm.sh
# Script to clean npm/yarn environment

echo "🧹 Cleaning project dependencies..."

# Remove node_modules folder
if [ -d "node_modules" ]; then
  rm -rf node_modules
  echo "✅ node_modules folder removed."
else
  echo "ℹ️ No node_modules folder found."
fi

# Remove package-lock.json if exists
if [ -f "package-lock.json" ]; then
  rm -f package-lock.json
  echo "✅ package-lock.json removed."
fi

# Remove yarn.lock if exists
if [ -f "yarn.lock" ]; then
  rm -f yarn.lock
  echo "✅ yarn.lock removed."
fi

# Remove pnpm-lock.yaml if exists
if [ -f "pnpm-lock.yaml" ]; then
  rm -f pnpm-lock.yaml
  echo "✅ pnpm-lock.yaml removed."
fi

# Clear npm cache
echo "🧽 Clearing npm cache..."
npm cache clean --force
echo "✅ npm cache cleared."

echo "✨ Cleanup complete!"
