#!/usr/bin/env bash
set -euo pipefail
usage(){ echo "Usage: $0 --fox-top <fox_12.1> --ramdisk <ramdisk-recovery.img> --output <zip>" >&2; exit 2; }
FOX_TOP=""; RAMDISK=""; OUTPUT=""
while [[ $# -gt 0 ]]; do case "$1" in --fox-top) FOX_TOP="$2"; shift 2;; --ramdisk) RAMDISK="$2"; shift 2;; --output) OUTPUT="$2"; shift 2;; *) usage;; esac; done
[[ -n "$FOX_TOP" && -n "$RAMDISK" && -n "$OUTPUT" ]] || usage
[[ -d "$FOX_TOP/vendor/recovery" && -f "$RAMDISK" ]] || { echo "Missing input" >&2; exit 3; }
for c in zip sha256sum gzip zstd cmp; do command -v "$c" >/dev/null || { echo "Missing host tool: $c" >&2; exit 4; }; done
SELF_DIR="$(cd "$(dirname "$0")" && pwd)"; TEMPLATE="$SELF_DIR/universal-installer/update-binary"; [[ -f "$TEMPLATE" ]] || exit 5
MB_HOST="$FOX_TOP/vendor/recovery/tools/magiskboot"; [[ -x "$MB_HOST" ]] || { echo "Missing host magiskboot" >&2; exit 5; }
WORK_BASE="${TMPDIR:-/tmp}"; mkdir -p "$WORK_BASE"; WORK="$(mktemp -d "$WORK_BASE/dash-installer.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/META-INF/com/google/android" "$WORK/tools" "$WORK/payload"
install -m0755 "$TEMPLATE" "$WORK/META-INF/com/google/android/update-binary"; printf '#MAGISK\n' > "$WORK/META-INF/com/google/android/updater-script"
install -m0755 "$FOX_TOP/vendor/recovery/prebuilt/arm64/busybox" "$WORK/tools/busybox"
install -m0755 "$FOX_TOP/vendor/recovery/prebuilt/arm64/magiskboot_updated" "$WORK/tools/magiskboot"
gzip -dc "$RAMDISK" > "$WORK/payload/ofox.raw.cpio"
zstd -q -f -19 -T1 "$WORK/payload/ofox.raw.cpio" -o "$WORK/payload/ofox-recovery.zst"
"$MB_HOST" compress=lz4_legacy "$WORK/payload/ofox.raw.cpio" "$WORK/payload/ofox-recovery.lz4_legacy" >/dev/null
zstd -q -dc "$WORK/payload/ofox-recovery.zst" > "$WORK/zstd.raw"; cmp -s "$WORK/payload/ofox.raw.cpio" "$WORK/zstd.raw" || exit 6
"$MB_HOST" decompress "$WORK/payload/ofox-recovery.lz4_legacy" "$WORK/lz4.raw" >/dev/null; cmp -s "$WORK/payload/ofox.raw.cpio" "$WORK/lz4.raw" || exit 6
rm -f "$WORK/payload/ofox.raw.cpio" "$WORK/zstd.raw" "$WORK/lz4.raw"
for p in "$WORK"/payload/ofox-recovery.*; do printf '%s  %s\n' "$(sha256sum "$p" | awk '{print $1}')" "$(basename "$p")" > "$p.sha256"; done
mkdir -p "$(dirname "$OUTPUT")"; rm -f "$OUTPUT"; (cd "$WORK" && zip -qr9 "$OUTPUT" .)
SIGNER="$FOX_TOP/vendor/recovery/signature/sign_zip.sh"; [[ -x "$SIGNER" ]] || exit 7; "$SIGNER" -z "$OUTPUT"
echo output="$OUTPUT"; sha256sum "$OUTPUT"; stat -c 'size=%s' "$OUTPUT"; sha256sum "$WORK"/payload/ofox-recovery.* | grep -v sha256
