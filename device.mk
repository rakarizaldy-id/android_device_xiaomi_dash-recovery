LOCAL_PATH := device/xiaomi/dash

PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true
ENABLE_VIRTUAL_AB := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

PRODUCT_BUILD_VENDOR_BOOT_IMAGE := true

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fuse.passthrough.enable=true \
    ro.twrp.vendor_boot=true \

# DASH ID303 crypto identity for recovery buildinfo. Keep AP2A/SDK34 userspace,
# but expose the stock Android 16 OS/SPL identity to KeyMint before native FBE.
PRODUCT_BUILD_PROP_OVERRIDES += \
    PLATFORM_VERSION_LAST_STABLE=16 \
    PLATFORM_SECURITY_PATCH=2026-08-01

AB_OTA_UPDATER := true
TARGET_ENFORCE_AB_OTA_PARTITION_LIST := true
AB_OTA_PARTITIONS += \
    boot dtbo init_boot lk mi_ext odm odm_dlkm preloader_raw product \
    system system_dlkm system_ext vbmeta vbmeta_system vbmeta_vendor \
    vendor vendor_boot vendor_dlkm

# DASH ID303 recovery-local crypto payload.
$(call inherit-product, $(LOCAL_PATH)/crypto_payload.mk)
$(call inherit-product, $(LOCAL_PATH)/vintf_payload.mk)

# DASH-local loader for the stock ID303 ODM host-touch implementation.
PRODUCT_PACKAGES += dash_touch_report

# DASH maintainer artwork stays device-local instead of modifying OrangeFox global theme source.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/assets/maintainer.png:$(TARGET_COPY_OUT_RECOVERY)/root/twres/images/Default/About/maintainer.png

# DASH recovery-local hooks used by OrangeFox native module/startup paths.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/bin/beforemodules.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/beforemodules.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/runatboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/runatboot.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/prefastboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/prefastboot.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/postfastboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/postfastboot.sh \
    $(LOCAL_PATH)/recovery/root/system/bin/fastbootd-touch.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/fastbootd-touch.sh
