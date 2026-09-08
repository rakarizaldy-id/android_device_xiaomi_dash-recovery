LOCAL_PATH := device/xiaomi/dash

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_DEVICE := dash
PRODUCT_NAME := twrp_dash
PRODUCT_BRAND := POCO
PRODUCT_MODEL := POCO X8 Pro Max
PRODUCT_MANUFACTURER := Xiaomi
