# OrangeFox Recovery for POCO X8 Pro Max (`dash`)

OrangeFox Recovery device tree for Xiaomi `dash`, based on MediaTek MT6991 with a `vendor_boot` v4 / Virtual A/B layout.

## Device information

| Specification | Value |
| --- | --- |
| Device | POCO X8 Pro Max / Redmi Turbo 5 Max |
| Codename | `dash` |
| SoC | MediaTek Dimensity 9500s |
| Platform | `mt6991` |
| Architecture | ARM64 |
| Partition scheme | Virtual A/B |
| Vendor boot header | v4 |
| Recovery layout | Recovery ramdisk in `vendor_boot` |
| Data filesystem | F2FS |
| Stock OS | Xiaomi HyperOS |
| Fenrir | Supported |

## Status — Beta 2

### Working
- Recovery boot
- Display and touchscreen
- FBE metadata and PIN/password decryption
- Internal storage
- MTP / ADB / sideload
- Backup / Restore
- Reboot modes
- ZIP/image flashing
- Haptics
- Flashlight
- USB OTG host storage
- FastbootD userspace transport

### Pending validation / known issue
- FastbootD touchscreen
- Format Data
- Dynamic partition operations

## Installation

Boot to fastboot and check the current slot:

```text
fastboot getvar current-slot
```

Flash Beta 2 to the matching `vendor_boot` slot:

```text
# Slot A
fastboot flash vendor_boot_a OrangeFox-R12.0-Unofficial-dash-Beta2.img

# Slot B
fastboot flash vendor_boot_b OrangeFox-R12.0-Unofficial-dash-Beta2.img
```

Then reboot to recovery:

```text
fastboot reboot recovery
```

## Source layout

```text
assets/        OrangeFox device resources
patches/       Small OrangeFox core patches required by DASH
recovery/      Recovery ramdisk configuration and runtime helpers
sepolicy/      Recovery SELinux policy
src/           Device-specific recovery helpers
tools/         Stock preparation, repack and verification tools
prebuilt/      Stock platform files supplied locally
proprietary/   Stock proprietary files supplied locally
```

## Building

Clone this tree to `device/xiaomi/dash`. Matching stock DASH payloads are required locally and are intentionally not redistributed here; see [`STOCK_PAYLOADS.md`](STOCK_PAYLOADS.md).

Validated stock baseline: `OS3.0.303.0.WPLIDXM`.

## Credits
- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer
Use at your own risk. Make sure the recovery image and firmware match the target device before flashing.
