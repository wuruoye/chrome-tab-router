#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_png="$project_dir/Resources/AppIcon.png"
output_icns="$project_dir/Resources/AppIcon.icns"

if [ ! -f "$source_png" ]; then
  echo "Missing icon source: $source_png" >&2
  exit 1
fi

temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/chrome-tab-router-icon.XXXXXX")
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
iconset="$temporary_dir/AppIcon.iconset"
mkdir "$iconset"

make_icon() {
  size=$1
  name=$2
  sips -s format png -z "$size" "$size" "$source_png" --out "$iconset/$name.png" >/dev/null
}

make_icon 16 icon_16x16
make_icon 32 icon_16x16@2x
make_icon 32 icon_32x32
make_icon 64 icon_32x32@2x
make_icon 128 icon_128x128
make_icon 256 icon_128x128@2x
make_icon 256 icon_256x256
make_icon 512 icon_256x256@2x
make_icon 512 icon_512x512
make_icon 1024 icon_512x512@2x

iconutil -c icns "$iconset" -o "$output_icns"
echo "Built $output_icns"
