#!/bin/zsh
set -eu
router_root="${0:A:h:h}"
router_bundle="$router_root/build/Chrome Tab Router.app"
router_staging="$router_root/build/.Chrome Tab Router.staging.app"
mkdir -p "$router_staging/Contents/MacOS" "$router_staging/Contents/Resources"
cp "$router_root/Resources/Info.plist" "$router_staging/Contents/Info.plist"
xcrun swiftc -swift-version 5 -O -target "$(uname -m)-apple-macosx13.0" \
    -framework AppKit -framework Carbon -framework ServiceManagement "$router_root"/Sources/*.swift \
    -o "$router_staging/Contents/MacOS/ChromeTabRouter"
osacompile -o "$router_staging/Contents/Resources/ChromeRouter.scpt" \
    "$router_root/Sources/ChromeRouter.applescript"
cp "$router_root/Resources/NativeHost" "$router_staging/Contents/Resources/NativeHost"
chmod +x "$router_staging/Contents/Resources/NativeHost"
if [[ -d "$router_root/ChromeExtension" ]]; then
    ditto "$router_root/ChromeExtension" "$router_staging/Contents/Resources/ChromeExtension"
fi
if [[ -f "$router_root/Resources/AppIcon.icns" ]]; then
    cp "$router_root/Resources/AppIcon.icns" "$router_staging/Contents/Resources/AppIcon.icns"
fi
codesign --force --sign - "$router_staging"
if [[ -d "$router_bundle" ]]; then rm -rf "$router_bundle"; fi
mv "$router_staging" "$router_bundle"
printf '%s\n' "$router_bundle"
