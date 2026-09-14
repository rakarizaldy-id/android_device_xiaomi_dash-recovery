#!/system/bin/sh

log=/tmp/dash_prefastboot.log
stage=/tmp/dash-fastbootd-odm
: > "$log"

slot="$(getprop ro.boot.slot_suffix)"
case "$slot" in
    _a|_b) ;;
    a|b) slot="_$slot" ;;
    *) echo "FAIL invalid_slot=$slot" >>"$log"; exit 0 ;;
esac

part="odm${slot}"
mapper="/dev/block/mapper/${part}"
mapped_by_us=0
mounted_by_us=0

if [ ! -e "$mapper" ]; then
    /system/bin/lptools map "$part" >>"$log" 2>&1
    [ "$?" -eq 0 ] && mapped_by_us=1
fi

for i in 1 2 3 4 5; do
    [ -e "$mapper" ] && break
    sleep 1
done
[ -e "$mapper" ] || exit 0

mkdir -p /odm
if ! grep -qs " /odm " /proc/mounts; then
    mount -t erofs -o ro "$mapper" /odm >>"$log" 2>&1
    [ "$?" -eq 0 ] && mounted_by_us=1
fi
grep -qs " /odm " /proc/mounts || {
    [ "$mapped_by_us" -eq 1 ] && /system/bin/lptools unmap "$part" >>"$log" 2>&1
    exit 0
}

rm -rf "$stage"
mkdir -p "$stage/lib64" "$stage/firmware"

for f in /odm/lib64/libtouchreport*.so /odm/lib64/libtensorflowlite_touch_c.so; do
    [ -f "$f" ] && cp -p "$f" "$stage/lib64/" >>"$log" 2>&1
done

for f in \
    /odm/firmware/*.tflite \
    /odm/firmware/novatek*.bin \
    /odm/firmware/p10u_nova_csot_thp_config.ini
do
    [ -f "$f" ] && cp -p "$f" "$stage/firmware/" >>"$log" 2>&1
done

if [ "$mounted_by_us" -eq 1 ]; then
    umount /odm >>"$log" 2>&1
fi
if [ "$mapped_by_us" -eq 1 ]; then
    /system/bin/lptools unmap "$part" >>"$log" 2>&1
fi

exit 0
