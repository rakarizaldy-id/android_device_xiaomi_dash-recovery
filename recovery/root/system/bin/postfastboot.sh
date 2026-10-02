#!/system/bin/sh

log=/tmp/dash_postfastboot.log
stage=/tmp/dash-fastbootd-odm
: > "$log"

if ! pidof dash_touch_report >/dev/null 2>&1; then
    [ -f "$stage/lib64/libtouchreport.so" ] || exit 0
    [ -f "$stage/firmware/p10u_nova_csot_thp_config.ini" ] || exit 0

    mkdir -p /odm
    grep -qs " /odm " /proc/mounts || \
        mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /odm 2>>"$log"

    mkdir -p /odm/lib64 /odm/firmware
    cp -p "$stage/lib64/"* /odm/lib64/ 2>>"$log" || true
    cp -p "$stage/firmware/"* /odm/firmware/ 2>>"$log" || true

    chcon u:object_r:vendor_file:s0 /odm /odm/lib64 /odm/firmware 2>>"$log" || true
    chcon u:object_r:vendor_file:s0 /odm/lib64/* /odm/firmware/* 2>>"$log" || true

    if [ -w /sys/module/firmware_class/parameters/path ]; then
        echo "/odm/firmware,/vendor/firmware" > /sys/module/firmware_class/parameters/path
    fi
fi

/system/bin/fastbootd-touch.sh >>"$log" 2>&1
exit 0
