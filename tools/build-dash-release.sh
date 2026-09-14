#!/usr/bin/env bash
set -eo pipefail

if [[ ! -f build/envsetup.sh ]]; then
  echo "Run this script from the Android source root." >&2
  exit 1
fi

export BUILD_USERNAME="${BUILD_USERNAME:-orangefox}"
export BUILD_HOSTNAME="${BUILD_HOSTNAME:-builder}"
unset CUSTOM_NINJA_BIN || true

rm -rf out/target/product/dash/recovery out/target/product/dash/obj/PACKAGING/recovery*
rm -f out/target/product/dash/recovery.img out/target/product/dash/ramdisk-recovery.img out/target/product/dash/ramdisk-recovery.cpio*
rm -f out/target/product/dash/root/prop.default
rm -f out/target/product/dash/ramdisk/system/etc/ramdisk/build.prop
rm -f out/target/product/dash/system/product/etc/build.prop
rm -f out/target/product/dash/system/system_ext/etc/build.prop
rm -f out/target/product/dash/system/vendor/build.prop
rm -f out/target/product/dash/system/vendor/odm/etc/build.prop

source build/envsetup.sh >/dev/null 2>&1 || true
lunch twrp_dash-eng
m recoveryimage -j"${JOBS:-16}"
