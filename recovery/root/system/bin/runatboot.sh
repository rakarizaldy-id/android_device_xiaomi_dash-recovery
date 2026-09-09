#!/system/bin/sh
# DASH late stock hardware bootstrap. Stock logical partitions remain authority.

[ "$(getprop ro.orangefox.fastbootd)" = "1" ] && exit 0

log=/tmp/dash_touch_runatboot.log
: > "$log"

echo "START uptime=$(cut -d' ' -f1 /proc/uptime)" >> "$log"
slot="$(getprop ro.boot.slot_suffix)"
case "$slot" in
    _a|_b) ;;
    a|b) slot="_$slot" ;;
    *) slot="" ;;
esac

vendor_dev="/dev/block/mapper/vendor${slot}"
odm_dev="/dev/block/mapper/odm${slot}"
dlkm_dev="/dev/block/mapper/vendor_dlkm${slot}"
[ -e "$vendor_dev" ] || vendor_dev="/dev/block/mapper/vendor_a"
[ -e "$vendor_dev" ] || vendor_dev="/dev/block/mapper/vendor_b"
[ -e "$odm_dev" ] || odm_dev="/dev/block/mapper/odm_a"
[ -e "$odm_dev" ] || odm_dev="/dev/block/mapper/odm_b"
[ -e "$dlkm_dev" ] || dlkm_dev="/dev/block/mapper/vendor_dlkm_a"
[ -e "$dlkm_dev" ] || dlkm_dev="/dev/block/mapper/vendor_dlkm_b"

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    [ -e "$odm_dev" ] && [ -e "$dlkm_dev" ] && break
    echo "WAIT_MAPPERS $i odm=$odm_dev dlkm=$dlkm_dev" >> "$log"
    sleep 1
done
[ -e "$odm_dev" ] || { echo "FAIL no ODM mapper" >> "$log"; exit 0; }
[ -e "$dlkm_dev" ] || { echo "FAIL no vendor_dlkm mapper" >> "$log"; exit 0; }

mkdir -p /odm /tmp/vendor_dlkm /tmp/vendor_stock
mountpoint -q /odm || mount -t erofs -o ro "$odm_dev" /odm >> "$log" 2>&1 || exit 0
mountpoint -q /tmp/vendor_dlkm || mount -t erofs -o ro "$dlkm_dev" /tmp/vendor_dlkm >> "$log" 2>&1 || exit 0
if [ -e "$vendor_dev" ]; then
    mountpoint -q /tmp/vendor_stock || mount -t erofs -o ro "$vendor_dev" /tmp/vendor_stock >> "$log" 2>&1 || mount -o ro "$vendor_dev" /tmp/vendor_stock >> "$log" 2>&1 || true
fi

echo "MOUNTS_READY" >> "$log"

# Preserve current-ROM DASH touch userspace before FastbootD unmaps super.
# /tmp is recovery-owned, so this remains valid after logical ODM disappears.
stage=/tmp/dash-fastbootd-odm
mkdir -p "$stage/lib64" "$stage/firmware"
for f in /odm/lib64/libtouchreport*.so /odm/lib64/libtensorflowlite_touch_c.so; do
    [ -f "$f" ] || continue
    cp -p "$f" "$stage/lib64/" >> "$log" 2>&1 || true
done
for f in /odm/firmware/*.tflite /odm/firmware/novatek*.bin; do
    [ -f "$f" ] || continue
    cp -p "$f" "$stage/firmware/" >> "$log" 2>&1 || true
done
echo "FBD_STAGE libs=$(ls "$stage/lib64" 2>/dev/null | wc -l) fw=$(ls "$stage/firmware" 2>/dev/null | wc -l)" >> "$log"
if [ -w /sys/module/firmware_class/parameters/path ]; then
    fw_path="/odm/firmware,/vendor/firmware"
    [ -d /tmp/vendor_stock/firmware ] && fw_path="/tmp/vendor_stock/firmware,$fw_path"
    echo "$fw_path" > /sys/module/firmware_class/parameters/path
fi

moddir=/tmp/vendor_dlkm/lib/modules
for mod in \
    xiaomi_spi_tee.ko \
    mtk_ioctl_touch_boost.ko \
    touch_boost.ko \
    xiaomi_touch_dash.ko \
    nt38771_touch_dash.ko
do
    name="${mod%.ko}"
    if grep -q "^${name} " /proc/modules 2>/dev/null; then
        echo "ALREADY $mod" >> "$log"
        continue
    fi
    insmod "$moddir/$mod" >> "$log" 2>&1
    rc=$?
    echo "INSMOD $mod RC=$rc" >> "$log"
    [ "$rc" -eq 0 ] || exit 0
done

if ! grep -q '^fs3002_haptic ' /proc/modules 2>/dev/null; then
    if [ -f "$moddir/fs3002_haptic.ko" ]; then
        insmod "$moddir/fs3002_haptic.ko" >> "$log" 2>&1
        echo "INSMOD fs3002_haptic.ko RC=$?" >> "$log"
    else
        echo "MISSING $moddir/fs3002_haptic.ko" >> "$log"
    fi
fi

for i in 1 2 3 4 5; do
    [ -e /dev/xiaomi-touch ] && grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null && break
    sleep 1
done

[ -e /dev/xiaomi-touch ] || { echo "FAIL no /dev/xiaomi-touch" >> "$log"; exit 0; }
grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null || { echo "FAIL no NVT input" >> "$log"; exit 0; }

chmod 0666 /dev/xiaomi-touch
[ -e /sys/class/touch/touch_dev/enable_touch_raw ] && echo 0 > /sys/class/touch/touch_dev/enable_touch_raw

if ! pidof dash_touch_report >/dev/null 2>&1; then
    export LD_LIBRARY_PATH=/odm/lib64:/vendor/lib64:/vendor/lib64/hw:/system/lib64:/sbin
    /system/bin/dash_touch_report >/tmp/dash_touch_report.log 2>&1 &
fi
sleep 1
echo "PASS reporter=$(pidof dash_touch_report)" >> "$log"
exit 0
