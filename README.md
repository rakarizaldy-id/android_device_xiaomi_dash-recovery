# OrangeFox Recovery for POCO X8 Pro Max (`dash`)

OrangeFox Recovery device tree for Xiaomi `dash`, based on the MediaTek MT6991 platform and `vendor_boot` v4 layout.

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

## Status

### Working

- Recovery boot
- Display and touchscreen
- FBE metadata decryption
- PIN/password decryption
- Internal storage

### Pending validation

- FastbootD
- MTP
- Format Data
- Backup / Restore
- Dynamic partition operations
- Reboot modes

## Source layout

```text
recovery/      Recovery ramdisk configuration
sepolicy/      Recovery SELinux policy
src/           Device-specific recovery helpers
tools/         Stock preparation and verification tools
prebuilt/      Stock platform files used locally
proprietary/   Stock proprietary files used locally
```

## Building

Clone this tree to:

```text
device/xiaomi/dash
```

Required stock files are taken from matching DASH firmware and verified before use. See [`STOCK_PAYLOADS.md`](STOCK_PAYLOADS.md).

## Compatibility

Validated stock baseline:

```text
OS3.0.303.0.WPLIDXM
```

## Credits

- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer

Use at your own risk. Make sure the image and firmware match the target device before flashing.
