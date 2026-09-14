# OrangeFox Recovery for POCO X8 Pro Max / Redmi Turbo 5 Max (`dash`)

Unofficial OrangeFox R12.0 device tree for Xiaomi `dash`, based on MediaTek MT6991 and a `vendor_boot` v4 / Virtual A/B layout.

> **Tested baseline:** HyperOS `OS3.0.303.0.WPLIDXM` · Android 16

## Device

| Item | Value |
| --- | --- |
| Codename | `dash` |
| Devices | POCO X8 Pro Max / Redmi Turbo 5 Max |
| SoC | MediaTek Dimensity 9500s / MT6991 |
| Architecture | ARM64 |
| Partition scheme | Virtual A/B |
| Recovery carrier | `vendor_boot` v4 recovery fragment |
| Data filesystem | F2FS |
| Recovery | OrangeFox R12.0 Unofficial |

## Release status

The HyperOS `vendor_boot` image is the tested and recommended installation path. The AOSP/Lineage installer is provided separately for compatible `vendor_boot` v4 carriers and remains experimental until validated per ROM.

| Component | Status |
| --- | --- |
| Recovery boot / display / touch | Working |
| HyperOS FBE PIN/password decrypt | Working |
| Internal storage / MTP / ADB / sideload | Working |
| Backup / Restore | Working |
| FastbootD / reboot modes | Working |
| USB OTG / haptics / flashlight / screenshot | Working |
| Shared OrangeFox settings lifecycle | Working |
| Advanced Wipe `Cache` | Working; wipe-only |
| Format Data | Not release-certified destructively |
| Destructive dynamic-partition operations | Not release-certified |
| AOSP / Lineage ROM-native installer | Experimental |

## Downloads

Use the repository **Releases** page.

| Asset | Use |
| --- | --- |
| `OrangeFox-R12.0-Unofficial-dash.img` | Tested full 64 MiB `vendor_boot` image for the supported HyperOS baseline |
| `OrangeFox-R12.0-Unofficial-dash-AOSP-Lineage-Installer.zip` | Experimental ROM-native installer for compatible AOSP/Lineage `vendor_boot` v4 carriers |

## Installation — HyperOS

Check the active slot first:

```text
fastboot getvar current-slot
```

Flash **only the active slot**:

```text
fastboot flash vendor_boot_a OrangeFox-R12.0-Unofficial-dash.img
# or, when the active slot is b:
fastboot flash vendor_boot_b OrangeFox-R12.0-Unofficial-dash.img
fastboot reboot recovery
```

Do not use `fastboot -w` for a normal recovery installation.

## AOSP / Lineage installer

The ZIP repacks the current compatible `vendor_boot` carrier and replaces its recovery fragment with OrangeFox while preserving carrier-owned platform data. It is **experimental** and should not be treated as universally compatible across ROMs.

For stock HyperOS, use the full `.img`; the stock carrier does not have enough fragment headroom for the ROM-native installer path.

## Building

Clone this repository as `device/xiaomi/dash`, apply the patches with `tools/apply-foundation-patches.sh`, provide the required local stock payloads, then build with `tools/build-dash-release.sh`.

This public repository intentionally does **not** redistribute Xiaomi/MediaTek proprietary binaries, trusted applications, firmware, or private runtime prebuilts. See [`STOCK_PAYLOADS.md`](STOCK_PAYLOADS.md).

## Credits

OrangeFox Recovery Project · TeamWin Recovery Project · Android Open Source Project

## Disclaimer

Unofficial recovery software. Verify the target device, active slot, firmware baseline, and release checksums before flashing.
