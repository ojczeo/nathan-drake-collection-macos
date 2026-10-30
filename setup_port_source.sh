#!/usr/bin/env bash
# Download the exact upstream BilalReloaded 0.7.2 sources (and git submodules).
# Never overwrite a local macOS-patched engine checkout.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
URL="https://github.com/bc160201983/Uncharted-The-Nathan-Drake-Collection-PC-port.git"
TAG="v0.7.2"
EXPECTED_SHA="7e53d912f8bb177a69b927df2fe4f87c9a1acf65"
MACOS_PORT="$ROOT/port-work/bilal"

if ! command -v git >/dev/null 2>&1; then
    echo "Git is required. Install Xcode Command Line Tools (xcode-select --install)." >&2
    exit 1
fi

if [[ -n "${PORT_CHECKOUT:-}" ]]; then
    if [[ "$PORT_CHECKOUT" == /* ]]; then
        TARGET="$PORT_CHECKOUT"
    else
        TARGET="$ROOT/$PORT_CHECKOUT"
    fi
elif [[ -e "$MACOS_PORT" || -L "$MACOS_PORT" ]]; then
    # The existing checkout may contain uncommitted, necessary macOS patches.
    TARGET="$ROOT/port-work/bilal-upstream-v0.7.2"
    echo "Preserving existing port-work/bilal. Upstream will be cloned separately."
else
    TARGET="$MACOS_PORT"
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    if [[ -d "$TARGET/.git" || -f "$TARGET/.git" ]]; then
        ACTUAL="$(git -C "$TARGET" rev-parse HEAD 2>/dev/null || true)"
        if [[ "$ACTUAL" == "$EXPECTED_SHA" ]]; then
            echo "Upstream $TAG already exists: $TARGET"
            echo "No files were changed. Check local modifications before using this checkout."
            exit 0
        fi
    fi
    echo "Refusing to replace existing directory: $TARGET" >&2
    echo "Specify another empty destination using PORT_CHECKOUT=port-work/other-name." >&2
    exit 1
fi

PARENT="$(dirname -- "$TARGET")"
mkdir -p -- "$PARENT"
STAGE="$(mktemp -d "$PARENT/.bilal-clone.XXXXXXXX")"
trap 'rm -rf -- "$STAGE"' EXIT

git clone --branch "$TAG" --recurse-submodules -- "$URL" "$STAGE/repo"
ACTUAL="$(git -C "$STAGE/repo" rev-parse HEAD)"
if [[ "$ACTUAL" != "$EXPECTED_SHA" ]]; then
    echo "Unexpected upstream commit: $ACTUAL (expected $EXPECTED_SHA)." >&2
    exit 1
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    echo "Target appeared during clone; refusing to overwrite: $TARGET" >&2
    exit 1
fi
mv -- "$STAGE/repo" "$TARGET"

echo "Cloned $TAG ($ACTUAL) to $TARGET"
if [[ "$TARGET" == "$MACOS_PORT" ]]; then
    echo "Important: fresh upstream is NOT yet macOS-patched or built."
else
    echo "Important: build_app.sh still uses the preserved port-work/bilal."
fi
echo "Port the macOS changes, then rebuild gow3-probe and libgow3gpu.dylib before packaging."
