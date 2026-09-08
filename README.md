# OrangeFox Recovery Device Tree for Xiaomi `dash`

Device configuration for building OrangeFox Recovery for Xiaomi/POCO devices with codename `dash`.

This tree follows the stock DASH `vendor_boot` v4 layout and keeps device-specific recovery integration isolated from the recovery framework.

## Device

| Item | Value |
| --- | --- |
| Codename | `dash` |
| Platform | MediaTek MT6991 |
| Architecture | ARM64 |
| Vendor boot header | v4 |
| Partition scheme | Virtual A/B |
| Recovery layout | Recovery ramdisk in `vendor_boot` |
| Data filesystem | F2FS |
| Recovery language | English |

## Status

**Functional / Testing**

Validated on-device:

- Recovery boot
- Display and touch
- FBE metadata decryption
- PIN/password decryption
- Internal storage
- KeyMint
- Gatekeeper
- Weaver
- Secure Element / OMAPI
- Boot Control

Pending validation:

- Fastbootd
- MTP
- Format Data
- Backup / Restore
- Dynamic partition operations
- Complete reboot matrix

## Source model

The stock DASH firmware is the platform authority for device-specific platform payloads and metadata.

This repository contains the recovery-side source and configuration. Proprietary firmware payloads are not redistributed here and must be supplied from the matching stock DASH firmware before building.

See [`STOCK_PAYLOADS.md`](STOCK_PAYLOADS.md) for the required stock payload layout and verification information.

## Repository layout

```text
recovery/   Recovery ramdisk configuration and init files
sepolicy/   Recovery-specific SELinux file contexts
src/        DASH recovery helper sources
tools/      Platform preparation and verification utilities
```
## Building

Place this tree at:

```text
device/xiaomi/dash
```

Prepare the required stock payloads first, then use the normal OrangeFox build environment for the target product defined by this tree.

The resulting recovery ramdisk is intended for the DASH stock `vendor_boot` v4 layout. Platform-specific boot components must remain sourced from the matching DASH stock firmware.

## Contributing

Changes should remain device-specific, reproducible, and validated on DASH hardware before being treated as working behavior.

Please keep unrelated platform payloads, build artifacts, local backups, and debugging output out of the repository.

## Credits

- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer

This project is provided for development and recovery use. Flashing custom recovery software carries risk; verify the target device and firmware before use.
