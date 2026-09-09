#!/system/bin/sh
# DASH stock hardware bootstrap. Runs before OrangeFox native vendor module loader.
# Stock logical partitions remain authority; mounts are read-only.

[ "$(getprop ro.orangefox.fastbootd)" = "1" ] && exit 0

slot="$(getprop ro.boot.slot_suffix)"
case "$slot" in
    _a|_b) ;;
    a|b) slot="_$slot" ;;
    *) slot="" ;;
esac

resolve_mapper() {
    local name="$1"
    local dev="/dev/block/mapper/${name}${slot}"
    [ -e "$dev" ] || dev="/dev/block/mapper/${name}_a"
    [ -e "$dev" ] || dev="/dev/block/mapper/${name}_b"
    [ -e "$dev" ] && echo "$dev"
}

vendor_dev="$(resolve_mapper vendor)"
odm_dev="$(resolve_mapper odm)"
dlkm_dev="$(resolve_mapper vendor_dlkm)"
[ -n "$odm_dev" ] || exit 0
[ -n "$dlkm_dev" ] || exit 0

mkdir -p /odm /vendor_dlkm /tmp/vendor_stock
mountpoint -q /odm || mount -t erofs -o ro "$odm_dev" /odm 2>/dev/null || mount -o ro "$odm_dev" /odm 2>/dev/null || exit 0
mountpoint -q /vendor_dlkm || mount -t erofs -o ro "$dlkm_dev" /vendor_dlkm 2>/dev/null || mount -o ro "$dlkm_dev" /vendor_dlkm 2>/dev/null || exit 0
if [ -n "$vendor_dev" ]; then
    mountpoint -q /tmp/vendor_stock || mount -t erofs -o ro "$vendor_dev" /tmp/vendor_stock 2>/dev/null || mount -o ro "$vendor_dev" /tmp/vendor_stock 2>/dev/null || true
fi
if [ -w /sys/module/firmware_class/parameters/path ]; then
    fw_path="/odm/firmware,/vendor/firmware"
    [ -d /tmp/vendor_stock/firmware ] && fw_path="/tmp/vendor_stock/firmware,$fw_path"
    echo "$fw_path" > /sys/module/firmware_class/parameters/path
fi

moddir=/vendor_dlkm/lib/modules
log=/tmp/dash_touch_modules.log
: > "$log"
for mod in \
    xiaomi_spi_tee.ko \
    mtk_ioctl_touch_boost.ko \
    touch_boost.ko \
    xiaomi_touch_dash.ko \
    nt38771_touch_dash.ko \
    fs3002_haptic.ko
do
    if [ ! -f "$moddir/$mod" ]; then
        echo "MISSING $moddir/$mod" >> "$log"
        continue
    fi
    name="${mod%.ko}"
    if grep -q "^${name} " /proc/modules 2>/dev/null; then
        echo "ALREADY $mod" >> "$log"
        continue
    fi
    insmod "$moddir/$mod" >> "$log" 2>&1
    echo "INSMOD $mod RC=$?" >> "$log"
done
