#!/bin/zsh
set -eu
router_root="${0:A:h:h}"
router_bundle="$router_root/build/Chrome Tab Router.app"
router_destination="$HOME/Applications/Chrome Tab Router.app"
zsh "$router_root/scripts/build.sh"
mkdir -p "$HOME/Applications"
if [[ -e "$router_destination" ]]; then
    router_existing_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$router_destination/Contents/Info.plist")
    if [[ "$router_existing_id" != 'com.sigma.ChromeTabRouter' ]]; then
        printf '%s\n' '安装目录已被其他应用占用。' >&2
        exit 1
    fi
    pkill -x -u "$(id -u)" ChromeTabRouter || true
fi
ditto "$router_bundle" "$router_destination"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$router_destination"
if ! open "$router_destination" --args --setup; then
    printf '%s\n' '应用文件已安装，但未能自动打开。请解锁 Mac 后手动打开应用。' >&2
fi
printf '%s\n' "$router_destination"
