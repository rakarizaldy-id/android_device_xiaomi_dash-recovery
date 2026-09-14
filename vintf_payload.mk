DEVICE_PATH := device/xiaomi/dash
DASH_VINTF_ROOT := $(DEVICE_PATH)/proprietary/vintf

DASH_DEVICE_VINTF := \
    android.hardware.boot-service.mtk.xml \
    android.se.omapi-service.xml

PRODUCT_COPY_FILES += \
    $(foreach f,$(DASH_DEVICE_VINTF),$(DASH_VINTF_ROOT)/$(f):recovery/root/vendor/etc/vintf/manifest/$(f))

PRODUCT_COPY_FILES += \
    $(DASH_VINTF_ROOT)/recovery-system-manifest.xml:recovery/root/system/etc/vintf/manifest.xml \
    $(DASH_VINTF_ROOT)/recovery-vendor-manifest.xml:recovery/root/system/etc/vintf/recovery_vendor/manifest.xml
