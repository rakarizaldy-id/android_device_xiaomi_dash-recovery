#!/system/bin/sh
# Release the current-ROM ODM touch reporter before super is unmapped.
# Its userspace payload was staged during normal recovery boot.
log=/tmp/dash_prefastboot.log
stage=/tmp/dash-fastbootd-odm
: > "$log"
echo "DASH_FBD PRE start" > /dev/kmsg 2>/dev/null || true

[ -f "$stage/lib64/libtouchreport.so" ] || {
    echo "FAIL no_early_stage" >> "$log"
    echo "DASH_FBD PRE no_early_stage" > /dev/kmsg 2>/dev/null || true
    exit 0
}
echo "PASS early_stage libs=$(ls "$stage/lib64" 2>/dev/null | wc -l) fw=$(ls "$stage/firmware" 2>/dev/null | wc -l)" >> "$log"
echo "DASH_FBD PRE staged_fw=$(ls "$stage/firmware"/novatek*.bin 2>/dev/null | wc -l)" > /dev/kmsg 2>/dev/null || true

pids="$(pidof dash_touch_report 2>/dev/null)"
[ -n "$pids" ] && kill $pids 2>/dev/null
for i in 1 2 3 4 5; do
    pidof dash_touch_report >/dev/null 2>&1 || break
    sleep 1
done
pids="$(pidof dash_touch_report 2>/dev/null)"
[ -n "$pids" ] && kill -9 $pids 2>/dev/null
sync

if lsof 2>/dev/null | grep -q "/odm/"; then
    echo "WARN odm_still_busy" >> "$log"
    lsof 2>/dev/null | grep "/odm/" >> "$log"
else
    echo "PASS odm_released" >> "$log"
    echo "DASH_FBD PRE odm_released" > /dev/kmsg 2>/dev/null || true
fi
exit 0
