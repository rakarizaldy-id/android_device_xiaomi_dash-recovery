#!/system/bin/sh
# Re-create only the DASH touch userspace view from tmpfs after super unmap.
log=/tmp/dash_postfastboot.log
stage=/tmp/dash-fastbootd-odm
: > "$log"
echo "DASH_FBD POST start" > /dev/kmsg 2>/dev/null || true

if grep -qs " /odm " /proc/mounts; then
    echo "FAIL odm_still_logical_mounted" >> "$log"
    exit 0
fi
[ -f "$stage/lib64/libtouchreport.so" ] || { echo "FAIL no_staged_touch" >> "$log"; exit 0; }

mkdir -p /odm
mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /odm || { echo "FAIL tmpfs_mount" >> "$log"; exit 0; }
mkdir -p /odm/lib64 /odm/firmware
cp -p "$stage/lib64/"* /odm/lib64/ 2>>"$log" || true
cp -p "$stage/firmware/"* /odm/firmware/ 2>>"$log" || true

echo "PASS tmpfs_odm libs=$(ls /odm/lib64 2>/dev/null | wc -l) fw=$(ls /odm/firmware 2>/dev/null | wc -l)" >> "$log"
echo "DASH_FBD POST tmpfs_fw=$(ls /odm/firmware/novatek*.bin 2>/dev/null | wc -l)" > /dev/kmsg 2>/dev/null || true
/system/bin/fastbootd-touch.sh >>"$log" 2>&1
echo "TOUCH_RC=$?" >> "$log"
exit 0
