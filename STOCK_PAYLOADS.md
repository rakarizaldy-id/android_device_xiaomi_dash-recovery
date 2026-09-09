# Stock payloads

This device tree depends on platform files from the matching stock DASH firmware.

The proprietary payloads themselves are intentionally not redistributed in this repository.

## Validated platform baseline

| Item | Value |
| --- | --- |
| Stock build | `OS3.0.303.0.WPLIDXM` |
| Platform | `mt6991` |
| `vendor_boot` SHA-256 | `fa6e6755d64b4bcbba007000c1a237a4cc67cc921e99c2a06a123b81a7de1a5e` |
| DTB SHA-256 | `2636d5a861e909f5bf32fb3b5c80b25824fbb6591e31a21b6b1326b6dc52d7e3` |

## Local layout

Before building, provide the stock files expected by the tree:

```text
prebuilt/stock/vendor_boot.img
prebuilt/stock/dtb/dash-id303.dtb
proprietary/crypto/vendor/...
```

The crypto payload file list is defined by `crypto_payload.mk`.
## Verification

`stock_crypto_sha256sums.txt` contains the expected hashes for the recovery crypto payload set.

`stock_vintf_sha256sums.txt` contains the expected hashes used by the platform preparation utilities.

Always verify stock-derived files before using them in a build. Do not substitute payloads from another device or firmware family.

## Platform handling

The recovery ramdisk is built for the stock DASH `vendor_boot` v4 structure. The stock platform fragment, DTB, boot configuration, and other platform-owned components are not replaced by this device tree.

Only the recovery-side content should be changed by recovery development.

## Recovery USB OTG module preparation

DASH stock DTBO advertises `mediatek,usb-offload` to the MTU3 host controller. The Android runtime provides the matching offload stack, but recovery does not use that Android userspace path.

For the **recovery copy only**, prepare the matching stock `mtu3.ko` with:

```text
python3 tools/patch-recovery-mtu3-offload.py --input <stock-mtu3.ko> --output <recovery-mtu3.ko>
```

The tool performs a same-size, single-literal neutralization and refuses unexpected inputs. Do not modify the stock/system module. The Beta 2 recovery image uses this recovery-only preparation; DTB, DTBO and the stock platform authority are otherwise left unchanged.
