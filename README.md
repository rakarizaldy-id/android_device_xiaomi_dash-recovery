# OrangeFox Recovery for POCO X8 Pro Max / Redmi Turbo 5 Max (`dash`)

Unofficial OrangeFox Recovery device tree for Xiaomi `dash`, targeting the MediaTek MT6991 platform and the stock `vendor_boot` v4 recovery layout.

This repository is intended to provide a clean, reproducible, device-specific recovery source for DASH while keeping platform-owned components tied to matching stock firmware.

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
| Stock OS family | Xiaomi HyperOS |

## Recovery status

**Functional / Testing**

### Validated on-device

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
- Complete reboot matrix

## Architecture

This tree follows the stock DASH `vendor_boot` v4 structure. Platform-owned components remain sourced from matching stock DASH firmware, while the recovery ramdisk and recovery-specific integration are maintained by this device tree.

The recovery implementation is designed to preserve the stock platform layout rather than replace device-specific platform components with cross-device equivalents.

## Stock firmware requirements

Proprietary platform payloads are not redistributed in this repository. They must be supplied from the matching stock DASH firmware before building and verified against the provided SHA-256 manifests.

No cross-device proprietary payloads are used.

See [`STOCK_PAYLOADS.md`](STOCK_PAYLOADS.md) for the expected local layout, validated stock baseline, and verification information.

## Repository layout

```text
recovery/      Recovery ramdisk configuration and init files
sepolicy/      Recovery-specific SELinux file contexts
src/           DASH recovery helper sources
tools/         Platform preparation and verification utilities
prebuilt/      Local stock platform payload location
proprietary/   Local stock proprietary payload location
```

## Building

Place this tree at:

```text
device/xiaomi/dash
```
Prepare the required stock payloads first, then use the normal OrangeFox build environment with the target product defined by this tree.

The resulting recovery ramdisk is intended for the DASH stock `vendor_boot` v4 structure. Platform-specific boot components must remain sourced from matching DASH stock firmware.

## Compatibility

Validated stock baseline:

```text
OS3.0.303.0.WPLIDXM
```

Compatibility should only be claimed after validation on physical DASH hardware. Support for additional firmware branches or ROM families may be documented as they are verified.

## Project goals

- Maintain a DASH-native OrangeFox recovery device tree.
- Preserve the stock platform layout where required.
- Keep recovery integration reproducible from source.
- Keep proprietary platform inputs verifiable.
- Validate functional changes on physical DASH hardware.

## Contributing

Changes should remain device-specific, reproducible, and validated on DASH hardware before being presented as working behavior.

Please keep unrelated platform payloads, build artifacts, local backups, and debugging output out of this repository.

## Credits

- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer

This project is provided for development and recovery use. Flashing custom recovery software carries risk; verify the target device and firmware before use.
