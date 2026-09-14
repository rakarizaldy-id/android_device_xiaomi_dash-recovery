# Local stock payloads

This repository contains the public device-tree source only. Proprietary Xiaomi/MediaTek payloads required by the tested DASH build are intentionally not redistributed.

The validated extraction baseline is HyperOS `OS3.0.303.0.WPLIDXM` / Android 16 for `dash`.

Provide the omitted files locally at the paths referenced by the build files:

- `compat/keymint_v3_prebuilt/android.hardware.security.keymint-V3-ndk.so`
- `prebuilt/runtime/system/bin/dash_omapi_bridge`
- `prebuilt/runtime/system/lib64/libdash_libcxx_compat.so`
- binary payloads referenced by `crypto_payload.mk` under `proprietary/crypto/`
- `proprietary/haptics/vendor/firmware/fs3002_haptic.bin`

The public VINTF/XML declarations are tracked in this repository. Runtime proprietary binaries and MiTEE trusted applications must come from the matching device firmware/build authority.

Do not substitute blobs from another device or firmware branch unless you have independently validated ABI and runtime compatibility.
