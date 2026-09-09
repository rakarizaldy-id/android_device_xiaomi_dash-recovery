#!/usr/bin/env python3
"""
Reconstruct a vendor_boot v4 image by replacing only the recovery ramdisk
fragment while preserving the base image's platform fragment, DTB and
structural AVB tail byte-for-byte.

This is the validated DASH repack model. Only the recovery fragment is
replaced; stock platform-owned components remain byte-preserved.
"""
from pathlib import Path
import argparse
import hashlib
import struct

def align(v, p):
    return (v + p - 1) // p * p

ap = argparse.ArgumentParser()
ap.add_argument("--base", required=True, help="validated base vendor_boot v4")
ap.add_argument("--recovery", required=True, help="new compressed recovery ramdisk fragment")
ap.add_argument("--output", required=True)
args = ap.parse_args()

base = Path(args.base).read_bytes()
rec = Path(args.recovery).read_bytes()

if base[:8] != b"VNDRBOOT":
    raise SystemExit("not vendor_boot")
hv, ps = struct.unpack_from("<II", base, 8)
if (hv, ps) != (4, 4096):
    raise SystemExit(f"unexpected header/page: {(hv, ps)}")

old_vrs = struct.unpack_from("<I", base, 24)[0]
hs = struct.unpack_from("<I", base, 2096)[0]
dtbs = struct.unpack_from("<I", base, 2100)[0]
ts, ne, es, bc = struct.unpack_from("<IIII", base, 2112)

if hs != 2128 or ne != 2 or es != 108:
    raise SystemExit("unexpected vendor_boot v4 table geometry")

roff = align(hs, ps)
doff = align(roff + old_vrs, ps)
toff = align(doff + dtbs, ps)

entries = []
for i in range(ne):
    o = toff + i * es
    size, off, typ = struct.unpack_from("<III", base, o)
    name = base[o + 12:o + 44]
    board = struct.unpack_from("<16I", base, o + 44)
    entries.append((size, off, typ, name, board))

if entries[0][2] != 1 or entries[1][2] != 2:
    raise SystemExit("unexpected ramdisk fragment ordering")

platform = base[roff:roff + entries[0][0]]
dtb = base[doff:doff + dtbs]
avb0 = base.find(b"AVB0", toff + ne * es)
if avb0 < 0:
    raise SystemExit("AVB0 structural footer not found")
avb_tail = base[avb0:]

header = bytearray(base[:ps])
struct.pack_into("<I", header, 24, len(platform) + len(rec))
struct.pack_into("<I", header, 2100, len(dtb))
struct.pack_into("<IIII", header, 2112, 216, 2, 108, 0)

img = bytearray(header)
img += platform
img += rec
img += b"\0" * (align(len(img), ps) - len(img))
img += dtb
img += b"\0" * (align(len(img), ps) - len(img))

for idx, (blob, off) in enumerate(((platform, 0), (rec, len(platform)))):
    _, _, typ, name, board = entries[idx]
    img += struct.pack("<III32s16I", len(blob), off, typ, name, *board)

img += b"\0" * (align(len(img), ps) - len(img))
used = len(img)
if used > avb0:
    raise SystemExit(f"payload overlaps AVB region: {used}>{avb0}")

img += b"\0" * (avb0 - len(img))
img += avb_tail

if len(img) != len(base):
    raise SystemExit("partition size changed")
if img[avb0:] != base[avb0:]:
    raise SystemExit("AVB tail changed")

Path(args.output).write_bytes(img)
print("output_sha256", hashlib.sha256(img).hexdigest())
print("platform_sha256", hashlib.sha256(platform).hexdigest())
print("dtb_sha256", hashlib.sha256(dtb).hexdigest())
print("avb_tail_sha256", hashlib.sha256(avb_tail).hexdigest())
print("headroom_before_AVB0", avb0 - used)
