DEVICE_PATH := device/xiaomi/dash
DASH_VINTF_ROOT := $(DEVICE_PATH)/proprietary/vintf
DASH_VINTF_MANIFEST_ROOT := $(DASH_VINTF_ROOT)/manifest

DASH_RECOVERY_DEVICE_VINTF :=     android.hardware.boot-service.mtk.xml     android.se.omapi-service.xml

DASH_RECOVERY_SECURITY_VINTF :=     android.hardware.gatekeeper-service.mitee.xml     android.hardware.secure_element-service.xiaomi.xml     android.hardware.security.keymint-service.mitee.xml     android.hardware.security.secureclock-service.mitee.xml     android.hardware.security.sharedsecret-service.mitee.xml     android.hardware.weaver-service.nxp.xml

PRODUCT_COPY_FILES +=     $(foreach f,$(DASH_RECOVERY_DEVICE_VINTF),$(DASH_VINTF_ROOT)/$(f):recovery/root/system/etc/vintf/manifest/$(f))     $(foreach f,$(DASH_RECOVERY_SECURITY_VINTF),$(DASH_VINTF_MANIFEST_ROOT)/$(f):recovery/root/system/etc/vintf/manifest/$(f))

PRODUCT_COPY_FILES +=     $(DASH_VINTF_ROOT)/recovery-system-manifest.xml:recovery/root/system/etc/vintf/manifest.xml
