#!/bin/bash

VERSION_FILE="ZYNTHBOXOS_BUILD_VERSION"

# Extract version number (remove 'v' prefix for processing)
CURRENT_VERSION=$(grep '^ZYNTHBOXOS_BUILD_VERSION=' "$VERSION_FILE" | cut -d'=' -f2 | sed 's/^v//')

# Update datetime
CURRENT_DATETIME=$(date -u +%Y-%m-%d_%H%M)

# Split into parts (MAJOR.MINOR.PATCH)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Default bump type is patch
BUMP_TYPE=${1:-patch}

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Unknown bump type: $BUMP_TYPE"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Replace old version with new version in file
sed -i "s/ZYNTHBOXOS_BUILD_VERSION=.*/ZYNTHBOXOS_BUILD_VERSION=$NEW_VERSION/" "$VERSION_FILE"

# Update the build datetime in file
sed -i "s/ZYNTHBOXOS_BUILD_DATETIME=.*/ZYNTHBOXOS_BUILD_DATETIME=$CURRENT_DATETIME/" "$VERSION_FILE"

echo "Version bumped: $CURRENT_VERSION → $NEW_VERSION"
