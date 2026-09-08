#!/system/bin/sh
# DASH late touch bootstrap. Stock ODM/vendor_dlkm remain authority.

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

odm_dev="/dev/block/mapper/odm${slot}"
dlkm_dev="/dev/block/mapper/vendor_dlkm${slot}"
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

mkdir -p /odm /tmp/vendor_dlkm
mountpoint -q /odm || mount -t erofs -o ro "$odm_dev" /odm >> "$log" 2>&1 || exit 0
mountpoint -q /tmp/vendor_dlkm || mount -t erofs -o ro "$dlkm_dev" /tmp/vendor_dlkm >> "$log" 2>&1 || exit 0

echo "MOUNTS_READY" >> "$log"
if [ -w /sys/module/firmware_class/parameters/path ]; then
    echo /vendor/firmware,/odm/firmware > /sys/module/firmware_class/parameters/path
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
