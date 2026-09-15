# OrangeFox Recovery for POCO X8 Pro Max (`dash`)

Unofficial OrangeFox R12.0 recovery for Xiaomi/POCO `dash`.

> **Tested baseline:** HyperOS `OS3.0.303.0.WPLIDXM` · Android 16

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

## Status — Stable

### Working

- Recovery boot
- Display and touchscreen
- FBE metadata and PIN/password decryption
- Internal storage
- MTP / ADB / sideload
- Backup / Restore
- ZIP and image flashing
- Reboot modes
- FastbootD
- USB OTG host storage — runtime tested
- Haptics
- Flashlight
- Screenshots

USB OTG storage is exposed through `/usb_otg` in `recovery.fstab` and appears in OrangeFox as `USB-Storage`.

The full `vendor_boot` image is the tested and recommended installation method for the supported HyperOS baseline.

An experimental installer ZIP is also provided for compatible AOSP / LineageOS ROMs.

## Downloads

| File | Description |
| --- | --- |
| `OrangeFox-R12.0-Unofficial-dash.img` | OrangeFox recovery image for the supported HyperOS baseline |
| `OrangeFox-R12.0-Unofficial-dash-AOSP-Lineage-Installer.zip` | Experimental installer for compatible AOSP / LineageOS ROMs |

## Installation

Boot to fastboot and check the current slot:

```text
fastboot getvar current-slot
```

Flash the image to the active `vendor_boot` slot:

```text
# Slot A
fastboot flash vendor_boot_a OrangeFox-R12.0-Unofficial-dash.img

# Slot B
fastboot flash vendor_boot_b OrangeFox-R12.0-Unofficial-dash.img
```

Then reboot to recovery:

```text
fastboot reboot recovery
```

## AOSP / LineageOS

The AOSP / LineageOS installer is experimental and intended only for compatible `vendor_boot` v4 ROMs. HyperOS users should use the full `.img` release.

## Source layout

```text
compat/        Compatibility modules
patches/       OrangeFox compatibility patches for DASH
recovery/      Recovery ramdisk configuration and runtime helpers
sepolicy/      Recovery SELinux policy
src/           Device-specific recovery helpers
tools/         Build and packaging tools
```

## Credits

- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer

This is an unofficial recovery build. Verify the target device, active slot, firmware baseline, and release checksums before flashing.
