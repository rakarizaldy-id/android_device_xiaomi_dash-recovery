DEVICE_PATH := device/xiaomi/dash
DASH_VINTF_ROOT := $(DEVICE_PATH)/proprietary/vintf

# Stock DASH device-manifest fragments. Stock PLATFORM also carries copies
# under /system/etc/vintf/manifest; those PLATFORM copies are pruned at pack
# time so libvintf does not merge device fragments into the framework manifest.
DASH_DEVICE_VINTF := \
    android.hardware.boot-service.mtk.xml \
    android.hardware.health-service.example.xml

PRODUCT_COPY_FILES += \
    $(foreach f,$(DASH_DEVICE_VINTF),$(DASH_VINTF_ROOT)/$(f):recovery/root/vendor/etc/vintf/manifest/$(f))
