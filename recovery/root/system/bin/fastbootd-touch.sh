#!/system/bin/sh
# FastbootD runs after the normal DASH module bootstrap but before/while super is unmapped.
# The touch reporter itself only depends on recovery /system libraries.
log=/tmp/dash_fastbootd_touch.log
: > "$log"
echo "START uptime=$(cut -d' ' -f1 /proc/uptime)" >> "$log"
echo "DASH_FBD START" > /dev/kmsg 2>/dev/null || true

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if [ -e /dev/xiaomi-touch ] && grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null; then
        break
    fi
    echo "WAIT_TOUCH $i" >> "$log"
    sleep 1
done

[ -e /dev/xiaomi-touch ] || { echo "FAIL no /dev/xiaomi-touch" >> "$log"; echo "DASH_FBD FAIL no_xiaomi_touch" > /dev/kmsg 2>/dev/null || true; exit 0; }
grep -q NVTCapacitiveTouchScreen /proc/bus/input/devices 2>/dev/null || { echo "FAIL no NVT input" >> "$log"; echo "DASH_FBD FAIL no_nvt_input" > /dev/kmsg 2>/dev/null || true; exit 0; }

chmod 0666 /dev/xiaomi-touch
[ -e /sys/class/touch/touch_dev/enable_touch_raw ] && echo 0 > /sys/class/touch/touch_dev/enable_touch_raw

if ! pidof dash_touch_report >/dev/null 2>&1; then
    export LD_LIBRARY_PATH=/odm/lib64:/system/lib64:/sbin
    /system/bin/dash_touch_report >/tmp/dash_touch_report_fastbootd.log 2>&1 &
fi
sleep 1
pid="$(pidof dash_touch_report 2>/dev/null)"
echo "PASS reporter=$pid" >> "$log"
if [ -n "$pid" ]; then
    echo "DASH_FBD PASS reporter=$pid nvt_fw=$(ls /odm/firmware/novatek*.bin 2>/dev/null | wc -l)" > /dev/kmsg 2>/dev/null || true
else
    echo "DASH_FBD FAIL reporter_dead nvt_fw=$(ls /odm/firmware/novatek*.bin 2>/dev/null | wc -l)" > /dev/kmsg 2>/dev/null || true
fi
exit 0
