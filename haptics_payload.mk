DEVICE_PATH := device/xiaomi/dash
DASH_HAPTICS_ROOT := $(DEVICE_PATH)/proprietary/haptics

PRODUCT_COPY_FILES += \
    $(DASH_HAPTICS_ROOT)/vendor/firmware/fs3002_haptic.bin:recovery/root/vendor/firmware/fs3002_haptic.bin
