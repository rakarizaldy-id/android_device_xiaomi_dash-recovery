DEVICE_PATH := device/xiaomi/dash
DASH_HAPTICS_ROOT := $(DEVICE_PATH)/proprietary/haptics

PRODUCT_COPY_FILES += \
    $(DASH_HAPTICS_ROOT)/vendor/firmware/fs3002_haptic.bin:recovery/root/vendor/firmware/fs3002_haptic.bin \
    $(DASH_HAPTICS_ROOT)/recovery/lib/modules/fs3002_haptic.ko:recovery/root/lib/modules/recovery/fs3002_haptic.ko \
    $(DASH_HAPTICS_ROOT)/recovery/lib/modules/modules.dep:recovery/root/lib/modules/recovery/modules.dep
