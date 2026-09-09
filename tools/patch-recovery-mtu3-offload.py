#!/usr/bin/env python3
"""Prepare the DASH recovery-only MTU3 module for USB OTG host mode.

The stock DASH DTBO advertises MediaTek USB offload to MTU3. Android boots the
full offload stack, but recovery does not provide its reserved-memory runtime.
For the recovery copy only, neutralize the DT property lookup literal while
keeping the module size unchanged. Never apply this to the system/stock copy.
"""
from pathlib import Path
import argparse
import hashlib

OLD = b"mediatek,usb-offload"
NEW = b"mediatek,usb-offloaX"

ap = argparse.ArgumentParser()
ap.add_argument("--input", required=True)
ap.add_argument("--output", required=True)
args = ap.parse_args()

src = Path(args.input).read_bytes()
count = src.count(OLD)
if count != 1:
    raise SystemExit(f"expected exactly one USB-offload literal, found {count}")

out = src.replace(OLD, NEW, 1)
if len(out) != len(src):
    raise SystemExit("module size changed")
if OLD in out or out.count(NEW) != 1:
    raise SystemExit("USB-offload neutralization verification failed")

Path(args.output).write_bytes(out)
print("input_sha256", hashlib.sha256(src).hexdigest())
print("output_sha256", hashlib.sha256(out).hexdigest())
print("size", len(out))
