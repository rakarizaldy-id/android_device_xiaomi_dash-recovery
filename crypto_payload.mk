DEVICE_PATH := device/xiaomi/dash
DASH_CRYPTO_ROOT := $(DEVICE_PATH)/proprietary/crypto

PRODUCT_PACKAGES += \
    libdash_libcxx_compat \
    dash_omapi_bridge

DASH_CRYPTO_HW_BIN := \
    android.hardware.gatekeeper-service.mitee \
    android.hardware.security.keymint@3.0-service.mitee \
    android.hardware.weaver-service.nxp \
    vendor.xiaomi.hardware.secure_element-service

PRODUCT_COPY_FILES += \
    $(DASH_CRYPTO_ROOT)/vendor/bin/tee-supplicant:recovery/root/vendor/bin/tee-supplicant \
    $(foreach f,$(DASH_CRYPTO_HW_BIN),$(DASH_CRYPTO_ROOT)/vendor/bin/hw/$(f):recovery/root/vendor/bin/hw/$(f))

DASH_CRYPTO_LIB64 := \
    android.hardware.secure_element-V1-ndk.so \
    android.hardware.secure_element@1.0.so \
    android.hardware.secure_element@1.1.so \
    android.hardware.secure_element@1.2.so \
    android.se.omapi-V1-ndk.so \
    ese_weaver.nxp.so \
    libclang_rt.ubsan_standalone-aarch64-android.so \
    libjc_keymint_transport.nxp.so \
    libmemunreachable.so \
    libmigpese@2.0.so \
    libmisight.so \
    libteecli.so \
    libtrusty.so \
    vendor.xiaomi.hardware.aidl.mtdservice-V1-ndk.so \
    vendor.xiaomi.hardware.miauthsecretd-V1-ndk.so

PRODUCT_COPY_FILES += \
    $(foreach f,$(DASH_CRYPTO_LIB64),$(DASH_CRYPTO_ROOT)/vendor/lib64/$(f):recovery/root/vendor/lib64/$(f)) \
    $(DASH_CRYPTO_ROOT)/vendor/etc/hal_uuid_map_dash.xml:recovery/root/vendor/etc/hal_uuid_map_dash.xml

DASH_CRYPTO_VINTF := \
    android.hardware.gatekeeper-service.mitee.xml \
    android.hardware.security.keymint-service.mitee.xml \
    android.hardware.security.secureclock-service.mitee.xml \
    android.hardware.security.sharedsecret-service.mitee.xml \
    android.hardware.weaver-service.nxp.xml

PRODUCT_COPY_FILES += \
    $(foreach f,$(DASH_CRYPTO_VINTF),$(DASH_CRYPTO_ROOT)/vendor/etc/vintf/manifest/$(f):recovery/root/vendor/etc/vintf/manifest/$(f))

DASH_CRYPTO_TA := \
    14b0aad8-c011-4a3f-b66aca8d0e66f273.ta \
    2e8fade5-0c7a-46cc-810e6468baee66b9.ta \
    377ee4e8-af0e-474f-a9d636a9268fe85c.ta \
    3d08821c-33a6-11e6-a1fa089e01c83aa2.ta \
    4d573443-6a56-4272-ac6f2425af9ef9bb.ta \
    59a4867c-9fe5-f7c2-b409a46bae6ff73e.ta \
    655a4b46-cd77-11ea-aafbf382a6988e7b.ta \
    68bcd09d-4101-4c0a-9552ed0af9ae16b2.ta \
    86f623f6-a299-4dfd-b560ffd3e5a62c29.ta \
    88ce8e6b-8646-4092-bb78faf5b55ff4df.ta \
    8aaaf201-2460-0000-7143fe4f7c823c80.ta \
    8aaaf201-2460-0000-aabbccdd00000006.ta \
    8aaaf201-2460-0010-aabbccdd00000006.ta \
    9811c1f6-47e3-5cea-ae6ef62ba433c4fd.ta \
    dba51a17-0563-11e7-93b16fa7b0071a51.ta \
    e5140b33-76fa-4c63-ab18062caab2fb5c.ta \
    e97c270e-a5c4-4c58-bcd3384a2fa2539e.ta

PRODUCT_COPY_FILES += \
    $(foreach f,$(DASH_CRYPTO_TA),$(DASH_CRYPTO_ROOT)/vendor/mitee/ta/$(f):recovery/root/vendor/mitee/ta/$(f))
