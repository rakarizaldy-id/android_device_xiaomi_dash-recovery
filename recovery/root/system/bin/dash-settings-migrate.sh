#!/system/bin/sh
MODE="${1:-predecrypt}"
ROOT=/persist/Fox
MARKER=$ROOT/.dash-migrated-v1
LEGACY_PERSIST=/persist/.foxs
LEGACY_FOX=/sdcard/Fox

mkdir -p "$ROOT" || exit 1

[ -f "$MARKER" ] && exit 0

if [ ! -f "$ROOT/.foxs" ] && [ -f "$LEGACY_PERSIST" ]; then
    cp -p "$LEGACY_PERSIST" "$ROOT/.foxs" && echo "I:DASH: migrated /persist/.foxs -> $ROOT/.foxs" >> /tmp/recovery.log
fi

[ "$MODE" = "postdecrypt" ] || exit 0

migrated=0
if [ ! -f "$ROOT/.foxs" ] && [ -f "$LEGACY_FOX/.foxs" ]; then
    cp -p "$LEGACY_FOX/.foxs" "$ROOT/.foxs" && migrated=1
fi
for name in .theme .navbar scaling; do
    if [ ! -e "$ROOT/$name" ] && [ -e "$LEGACY_FOX/$name" ]; then
        cp -a "$LEGACY_FOX/$name" "$ROOT/$name" && migrated=1
    fi
done
touch "$MARKER"
if [ "$migrated" = "1" ]; then
    touch /tmp/dash-ui-state-migrated
    echo "I:DASH: one-time legacy UI state import completed" >> /tmp/recovery.log
fi
sync
exit 0
