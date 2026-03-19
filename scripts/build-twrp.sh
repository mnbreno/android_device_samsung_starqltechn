#!/usr/bin/env bash
# Build TWRP for SM-G9600 (starqltechn) and package recovery.img for Odin.
# Run from the device tree repo root on Linux with repo, JDK, and build deps installed.
# See README and minimal-manifest-twrp docs for prerequisites.

set -e

DEVICE_TREE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${1:-$DEVICE_TREE_ROOT/twrp_build}"
MANIFEST_URL="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git"
MANIFEST_BRANCH="twrp-9.0"
DEVICE_PATH="device/samsung/starqltechn"
LUNCH_TARGET="omni_starqltechn-eng"
OUT_RECOVERY="out/target/product/starqltechn/recovery.img"

cd "$DEVICE_TREE_ROOT"
REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "android-10")"
if [[ -z "$REMOTE_URL" ]]; then
  echo "Could not get git remote URL. Using defaults for local manifest."
  REMOTE_URL="https://github.com/mnbreno/android_device_samsung_starqltechn.git"
fi
# Convert URL to org/repo form for manifest name
REPO_NAME="${REMOTE_URL%.git}"
REPO_NAME="${REPO_NAME#*github.com[:/]}"

echo "Device tree: $DEVICE_TREE_ROOT"
echo "Build root:  $BUILD_ROOT"
echo "Branch:      $BRANCH"
echo "Repo name:   $REPO_NAME"

mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"

if [[ ! -d .repo ]]; then
  echo "Initializing repo..."
  repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH"
fi

mkdir -p .repo/local_manifests
cat > .repo/local_manifests/starqltechn.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="github" fetch="https://github.com/" />
  <project path="$DEVICE_PATH"
           name="$REPO_NAME"
           remote="github"
           revision="$BRANCH" />
</manifest>
EOF

echo "Syncing..."
repo sync -c -j4

echo "Building..."
source build/envsetup.sh
lunch "$LUNCH_TARGET"
mka recoveryimage

if [[ ! -f "$OUT_RECOVERY" ]]; then
  echo "Build failed: $OUT_RECOVERY not found."
  exit 1
fi

RELEASE_DIR="$BUILD_ROOT/release"
mkdir -p "$RELEASE_DIR"
TAR_NAME="twrp-starqltechn-android10-$(date +%Y%m%d).tar"
cp "$OUT_RECOVERY" "$RELEASE_DIR/recovery.img"
cd "$RELEASE_DIR"
tar -cvf "$TAR_NAME" recovery.img
cd "$DEVICE_TREE_ROOT"

echo ""
echo "Build complete."
echo "Odin-ready tarball: $BUILD_ROOT/release/$TAR_NAME"
echo ""
echo "To release on GitHub:"
echo "  1. Create a new Release (tag e.g. v1.0-android10) at https://github.com/mnbreno/android_device_samsung_starqltechn/releases/new"
echo "  2. Upload $BUILD_ROOT/release/$TAR_NAME as a release asset."
echo "  Or use: gh release create <tag> $BUILD_ROOT/release/$TAR_NAME --title 'TWRP starqltechn Android 10'"
echo ""
