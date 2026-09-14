#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 --base vendor_boot.img --ramdisk ramdisk-recovery.img --output OrangeFox-dash.img" >&2
    exit 2
}

BASE=""; RAMDISK=""; OUTPUT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --base) BASE="$2"; shift 2 ;;
        --ramdisk) RAMDISK="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) usage ;;
    esac
done
[[ -n "$BASE" && -n "$RAMDISK" && -n "$OUTPUT" ]] || usage
[[ -f "$BASE" && -f "$RAMDISK" ]] || { echo "Missing input file" >&2; exit 3; }

for cmd in gzip zstd python3 cmp sha256sum; do
    command -v "$cmd" >/dev/null || { echo "Missing tool: $cmd" >&2; exit 4; }
done

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
REPACK="$SELF_DIR/repack-dash-vendor-boot.py"
[[ -x "$REPACK" || -f "$REPACK" ]] || { echo "Missing repacker: $REPACK" >&2; exit 5; }
WORK_BASE="${TMPDIR:-/tmp}"
mkdir -p "$WORK_BASE"
WORK="$(mktemp -d "$WORK_BASE/dash-vendor-boot.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

magic="$(od -An -tx1 -N4 "$RAMDISK" | tr -d ' \n')"
case "$magic" in
    1f8b0800|1f8b08*)
        gzip -dc "$RAMDISK" > "$WORK/recovery.cpio"
        ;;
    28b52ffd)
        zstd -q -dc "$RAMDISK" > "$WORK/recovery.cpio"
        ;;
    *)
        echo "Unsupported recovery ramdisk compression magic: $magic" >&2
        exit 6
        ;;
esac

zstd -q -f -19 -T1 "$WORK/recovery.cpio" -o "$WORK/recovery.zst"
zstd -q -dc "$WORK/recovery.zst" > "$WORK/roundtrip.cpio"
cmp -s "$WORK/recovery.cpio" "$WORK/roundtrip.cpio" || {
    echo "ZSTD round-trip mismatch" >&2
    exit 7
}
mkdir -p "$(dirname "$OUTPUT")"
python3 "$REPACK" --base "$BASE" --recovery "$WORK/recovery.zst" --output "$OUTPUT"

printf 'ramdisk_input_sha256 '
sha256sum "$RAMDISK" | awk '{print $1}'
printf 'cpio_sha256 '
sha256sum "$WORK/recovery.cpio" | awk '{print $1}'
printf 'zstd_fragment_sha256 '
sha256sum "$WORK/recovery.zst" | awk '{print $1}'
printf 'output_sha256 '
sha256sum "$OUTPUT" | awk '{print $1}'
stat -c 'output_size %s' "$OUTPUT"
zstd -lv "$WORK/recovery.zst"
