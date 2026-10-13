#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$project_dir" <<'PY'
import json
import pathlib
import struct
import sys
import zipfile

project = pathlib.Path(sys.argv[1])
source = project / "ChromeExtension"
manifest_path = source / "manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

if manifest.get("manifest_version") != 3:
    raise SystemExit("扩展必须使用 Manifest V3。")

version = manifest.get("version")
if not isinstance(version, str) or not version:
    raise SystemExit("manifest.json 缺少 version。")

icons = manifest.get("icons") or {}
icon128 = icons.get("128")
if not isinstance(icon128, str):
    raise SystemExit("manifest.json 缺少 128×128 扩展图标；请先把图标加入 ChromeExtension 并在 icons.128 中引用。")

icon_path = (source / icon128).resolve()
if not icon_path.is_relative_to(source.resolve()) or not icon_path.is_file():
    raise SystemExit(f"扩展图标不存在：{icon128}")

with icon_path.open("rb") as image:
    header = image.read(24)
if header[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack(">II", header[16:24]) != (128, 128):
    raise SystemExit(f"扩展图标必须是 128×128 PNG：{icon128}")

files = []
for path in sorted(source.rglob("*")):
    relative = path.relative_to(source)
    if any(part.startswith(".") or part == "__MACOSX" for part in relative.parts):
        continue
    if path.is_symlink():
        raise SystemExit(f"扩展目录中不能包含符号链接：{relative}")
    if path.is_file():
        files.append((relative.as_posix(), path))

if not any(name == "manifest.json" for name, _ in files):
    raise SystemExit("ZIP 根目录缺少 manifest.json。")

output_dir = project / "build"
output_dir.mkdir(parents=True, exist_ok=True)
output = output_dir / f"chrome-tab-router-extension-{version}.zip"
with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
    for name, path in files:
        entry = zipfile.ZipInfo(name, date_time=(2020, 1, 1, 0, 0, 0))
        entry.compress_type = zipfile.ZIP_DEFLATED
        entry.external_attr = 0o644 << 16
        archive.writestr(entry, path.read_bytes())

with zipfile.ZipFile(output) as archive:
    damaged = archive.testzip()
    if damaged:
        raise SystemExit(f"ZIP 文件校验失败：{damaged}")

print(f"已生成 {output}（{len(files)} 个扩展文件）")
PY
