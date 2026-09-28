<div align="center">


# OrangeFox Recovery · R12.0

### POCO X8 Pro Max `dash`


</div>


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

## Feature Status

| Feature | Status | | Feature | Status |
|:---|:---:|:---:|:---|:---:|
| Recovery boot | ✅ | | Reboot modes | ✅ |
| Display & touchscreen | ✅ | | FastbootD | ✅ |
| FBE metadata decryption | ✅ | | USB OTG | ✅ |
| Internal storage | ✅ | | Haptics | ✅ |
| MTP / ADB / sideload | ✅ | | Flashlight | ✅ |
| Backup / Restore | ✅ | | Screenshots | ✅ |
| ZIP & image flashing | ✅ | | RGB Indicator | ✅ |


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

## Credits

- OrangeFox Recovery Project
- TeamWin Recovery Project
- Android Open Source Project

## Disclaimer

This is an unofficial recovery build. Verify the target device, active slot, firmware baseline, and release checksums before flashing.
