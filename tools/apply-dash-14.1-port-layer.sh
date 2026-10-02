#!/usr/bin/env bash
set -euo pipefail
SELF="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -n "${1:-}" ]]; then
  TOP="$(cd "$1" && pwd)"
elif [[ -d "$SELF/../../../bootable/recovery" ]]; then
  TOP="$(cd "$SELF/../../.." && pwd)"
else
  echo "Cannot locate source tree" >&2
  exit 2
fi
ARCHIVE="$SELF/prebuilt/port/dash-14.1-port-layer.tar.zst"
SUMFILE="$SELF/prebuilt/port/dash-14.1-port-layer.sha256"
EXPECTED="$(awk '{print $1}' "$SUMFILE")"
ACTUAL="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
[[ "$ACTUAL" == "$EXPECTED" ]] || { echo "Port layer checksum mismatch" >&2; exit 3; }
WORK="$TOP/.dash-port-layer"
rm -rf "$WORK"
mkdir -p "$WORK"
zstd -q -dc "$ARCHIVE" | tar -xf - -C "$WORK"
LAYER="$WORK/layer"
apply_one() {
  patch --forward --batch --fuzz=0 -d "$TOP/$1" -p1 < "$LAYER/$2"
}
apply_one build/make upstream/patch-manifest-fox_14.1.diff
if [[ -f "$TOP/.repo/manifests/remove-minimal.xml" ]]; then
  apply_one .repo/manifests upstream/patch-remove-minimal-fox_14.1.diff
fi
apply_one system/update_engine upstream/patch-update-engine-fox_14.1.diff
apply_one build/make patches/build-make-vendorboot-nonavb-14.1.patch
apply_one vendor/recovery patches/vendor-recovery-reference-vendorboot-absolute-path-14.1.patch
BOOT_PATCHES=(
  bootable-recovery-native-runtime-14.1.patch
  bootable-recovery-dash-rgb-ring-14.1.patch
  bootable-recovery-dash-runtime-hooks-14.1.patch
  bootable-recovery-dash-usbotg-ui-14.1.patch
  bootable-recovery-dash-persist-splash-14.1.patch
  bootable-recovery-dash-splash-preview-geometry-14.1.patch
  bootable-recovery-dash-removable-wipe-ui-14.1.patch
  bootable-recovery-dash-mount-ui-14.1.patch
  bootable-recovery-dash-select-storage-ui-14.1.patch
  bootable-recovery-dash-part-option-ui-14.1.patch
  bootable-recovery-dash-usbotg-usable-storage-14.1.patch
  bootable-recovery-dash-usbotg-quickaccess-14.1.patch
  bootable-recovery-dash-filemanager-cleanup-14.1.patch
  bootable-recovery-dash-fox-addon-cutout-14.1.patch
  bootable-recovery-dash-aromafm-cutout-14.1.patch
  bootable-recovery-dash-initd-cutout-14.1.patch
  bootable-recovery-dash-32-runtime-14.1.patch
  bootable-recovery-dash-33-native-usbotg-14.1.patch
  bootable-recovery-dash-34-system-cleanup-14.1.patch
  bootable-recovery-dash-35-release-banner-14.1.patch
)
for p in "${BOOT_PATCHES[@]}"; do
  apply_one bootable/recovery "patches/$p"
done
apply_one system/vold patches/system-vold-dash-native-crypto-14.1.patch
python3 "$LAYER/patch-dash-fox-addons.py" "$TOP/vendor/recovery"
SRC="$SELF/recovery/root/twres/images/Default/About/maintainer.png"
DST="$TOP/bootable/recovery/gui/theme/portrait_hdpi/images/Default/About/maintainer.png"
mkdir -p "$(dirname "$DST")"
install -m 0644 "$SRC" "$DST"
rm -rf "$WORK"
echo "Dash 14.1 port layer applied"
