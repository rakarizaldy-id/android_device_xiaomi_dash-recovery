LOCAL_PATH := device/xiaomi/dash

PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true
ENABLE_VIRTUAL_AB := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false
PRODUCT_BUILD_RECOVERY_IMAGE := true
AB_OTA_UPDATER := true
TARGET_ENFORCE_AB_OTA_PARTITION_LIST := true
AB_OTA_PARTITIONS += \
    boot dtbo init_boot lk mi_ext odm odm_dlkm preloader_raw product \
    system system_dlkm system_ext vbmeta vbmeta_system vbmeta_vendor \
    vendor vendor_boot vendor_dlkm

$(call inherit-product, device/xiaomi/dash/crypto_payload.mk)
$(call inherit-product, device/xiaomi/dash/vintf_payload.mk)
$(call inherit-product, device/xiaomi/dash/haptics_payload.mk)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/runtime/system/bin/dash_omapi_bridge:recovery/root/system/bin/dash_omapi_bridge \
    $(LOCAL_PATH)/prebuilt/runtime/system/lib64/libdash_libcxx_compat.so:recovery/root/system/lib64/libdash_libcxx_compat.so

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fuse.passthrough.enable=true \
    ro.twrp.vendor_boot=true \
    ro.recovery.usb.vid=18D1 \
    ro.recovery.usb.adb.pid=D001 \
    ro.recovery.usb.fastboot.pid=4EE0 \
    ro.fsck_no_kernel_check=true

PRODUCT_BUILD_PROP_OVERRIDES += \
    PLATFORM_VERSION_LAST_STABLE=16 \
    PLATFORM_SECURITY_PATCH=2026-08-01

PRODUCT_PACKAGES += \
    dash_touch_report \
    dash_keymint_v3_compat \
    android.hardware.security.rkp-V3-ndk \
    android.hardware.security.secureclock-V1-ndk \
    android.hardware.security.sharedsecret-V1-ndk
