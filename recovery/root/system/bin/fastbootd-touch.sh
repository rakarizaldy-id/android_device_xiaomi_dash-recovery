#!/system/bin/sh

log=/tmp/dash_fastbootd_touch.log
: > "$log"

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if [ -e /dev/xiaomi-touch ] && \
       grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null; then
        break
    fi
    sleep 1
done

[ -e /dev/xiaomi-touch ] || exit 0
grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null || exit 0

chmod 0666 /dev/xiaomi-touch
[ -e /sys/class/touch/touch_dev/enable_touch_raw ] && \
    echo 0 > /sys/class/touch/touch_dev/enable_touch_raw

if ! pidof dash_touch_report >/dev/null 2>&1; then
    export LD_LIBRARY_PATH=/odm/lib64:/vendor/lib64:/vendor/lib64/hw:/system/lib64:/sbin
    /system/bin/dash_touch_report >"$log" 2>&1 &
fi

exit 0
