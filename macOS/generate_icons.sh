#!/bin/bash
#
# Generate macOS app icon PNGs from SVG source.
# Requires either rsvg-convert (from librsvg, via Homebrew) or falls back to sips.
#
# Usage: ./generate_icons.sh [path/to/icon.svg]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SVG_INPUT="${1:-$SCRIPT_DIR/../Assets/icon.svg}"
OUTPUT_DIR="$SCRIPT_DIR/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SVG_INPUT" ]; then
    echo "Error: SVG file not found at $SVG_INPUT"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# macOS icon sizes: the pixel sizes needed for each slot
# Format: "filename pixel_size"
ICON_SPECS=(
    "icon_16x16.png 16"
    "icon_16x16@2x.png 32"
    "icon_32x32.png 32"
    "icon_32x32@2x.png 64"
    "icon_128x128.png 128"
    "icon_128x128@2x.png 256"
    "icon_256x256.png 256"
    "icon_256x256@2x.png 512"
    "icon_512x512.png 512"
    "icon_512x512@2x.png 1024"
)

generate_with_rsvg() {
    local svg="$1" output="$2" size="$3"
    rsvg-convert -w "$size" -h "$size" "$svg" -o "$output"
}

generate_with_sips() {
    local svg="$1" output="$2" size="$3"
    # sips cannot read SVG directly; first convert to a large PNG via a temp file,
    # then resize. We create one master PNG and resize from it.
    if [ ! -f "$MASTER_PNG" ]; then
        # Try using qlmanage to render SVG to PNG
        local tmpdir
        tmpdir=$(mktemp -d)
        qlmanage -t -s 1024 -o "$tmpdir" "$svg" 2>/dev/null || true
        local rendered="$tmpdir/$(basename "$svg").png"
        if [ -f "$rendered" ]; then
            cp "$rendered" "$MASTER_PNG"
            rm -rf "$tmpdir"
        else
            rm -rf "$tmpdir"
            echo "Error: Cannot convert SVG. Install rsvg-convert: brew install librsvg"
            exit 1
        fi
    fi
    sips -z "$size" "$size" "$MASTER_PNG" --out "$output" >/dev/null 2>&1
}

MASTER_PNG=$(mktemp /tmp/nemjpg_master_XXXXXX.png)
trap "rm -f '$MASTER_PNG'" EXIT

# Determine which tool to use
if command -v rsvg-convert &>/dev/null; then
    CONVERTER="rsvg"
    echo "Using rsvg-convert"
else
    CONVERTER="sips"
    echo "Using sips (via qlmanage for SVG rendering)"
fi

echo "Source: $SVG_INPUT"
echo "Output: $OUTPUT_DIR"
echo ""

for spec in "${ICON_SPECS[@]}"; do
    filename=$(echo "$spec" | awk '{print $1}')
    size=$(echo "$spec" | awk '{print $2}')
    output="$OUTPUT_DIR/$filename"

    if [ "$CONVERTER" = "rsvg" ]; then
        generate_with_rsvg "$SVG_INPUT" "$output" "$size"
    else
        generate_with_sips "$SVG_INPUT" "$output" "$size"
    fi

    echo "  Generated $filename (${size}x${size})"
done

echo ""
echo "Done! Icon PNGs generated in $OUTPUT_DIR"
