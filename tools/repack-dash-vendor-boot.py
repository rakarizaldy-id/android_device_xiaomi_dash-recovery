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

FDT_MAGIC = 0xD00DFEED
FDT_BEGIN_NODE = 1
FDT_END_NODE = 2
FDT_PROP = 3
FDT_NOP = 4
FDT_END = 9
USB_HOST_SYMBOL = b"/soc/usb0@16701000/xhci0@16700000\0"
USB_HOST_RECOVERY_TARGET = b"/soc/usb0@16701000\0"


def align(v, p):
    return (v + p - 1) // p * p


def patch_usb_host_symbol(blob: bytes) -> bytes:
    if len(blob) < 40:
        raise SystemExit("DTB too small")

    fdt_magic = struct.pack(">I", FDT_MAGIC)
    fdt_off = blob.find(fdt_magic)
    if fdt_off < 0:
        raise SystemExit("FDT payload not found in DTB container")

    (magic, totalsize, off_struct, off_strings, _off_mem_rsvmap,
     version, last_comp_version, _boot_cpuid_phys,
     size_strings, size_struct) = struct.unpack_from(">10I", blob, fdt_off)

    if magic != FDT_MAGIC:
        raise SystemExit("invalid FDT magic")
    if fdt_off + totalsize > len(blob):
        raise SystemExit("truncated FDT payload")
    if version < 17 or last_comp_version > 17:
        raise SystemExit(f"unexpected DTB version: {version}/{last_comp_version}")
    if off_struct + size_struct > totalsize or off_strings + size_strings > totalsize:
        raise SystemExit("invalid FDT block bounds")

    out = bytearray(blob)
    struct_base = fdt_off + off_struct
    strings_base = fdt_off + off_strings
    pos = struct_base
    end = struct_base + size_struct
    stack = []
    patched = False

    while pos < end:
        token = struct.unpack_from(">I", out, pos)[0]
        pos += 4

        if token == FDT_BEGIN_NODE:
            nul = out.find(0, pos, end)
            if nul < 0:
                raise SystemExit("unterminated DTB node name")
            name = bytes(out[pos:nul]).decode("ascii", "strict")
            stack.append(name)
            pos = align(nul + 1, 4)
        elif token == FDT_END_NODE:
            if not stack:
                raise SystemExit("unbalanced DTB nodes")
            stack.pop()
        elif token == FDT_PROP:
            if pos + 8 > end:
                raise SystemExit("truncated DTB property")
            length, nameoff = struct.unpack_from(">II", out, pos)
            pos += 8
            data_pos = pos
            data_end = data_pos + length
            if data_end > end:
                raise SystemExit("truncated DTB property data")

            name_pos = strings_base + nameoff
            if name_pos >= strings_base + size_strings:
                raise SystemExit("invalid FDT property name offset")
            name_end = out.find(0, name_pos, strings_base + size_strings)
            if name_end < 0:
                raise SystemExit("unterminated DTB property name")
            prop_name = bytes(out[name_pos:name_end]).decode("ascii", "strict")

            path = "/" + "/".join(x for x in stack if x)
            if path == "/__symbols__" and prop_name == "usb_host":
                current = bytes(out[data_pos:data_end])
                if current != USB_HOST_SYMBOL:
                    raise SystemExit(
                        "unexpected /__symbols__/usb_host value: " + repr(current)
                    )
                replacement = USB_HOST_RECOVERY_TARGET.ljust(length, b"\0")
                if len(replacement) != length:
                    raise SystemExit("usb_host replacement does not fit in-place")
                out[data_pos:data_end] = replacement
                patched = True

            pos = align(data_end, 4)
        elif token == FDT_NOP:
            continue
        elif token == FDT_END:
            break
        else:
            raise SystemExit(f"unknown DTB token: 0x{token:08x}")

    if not patched:
        raise SystemExit("/__symbols__/usb_host was not found")
    if len(out) != len(blob):
        raise SystemExit("DTB size changed")
    return bytes(out)


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
dtb_input = base[doff:doff + dtbs]
dtb = patch_usb_host_symbol(dtb_input)
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
print("dtb_input_sha256", hashlib.sha256(dtb_input).hexdigest())
print("dtb_output_sha256", hashlib.sha256(dtb).hexdigest())
print("avb_tail_sha256", hashlib.sha256(avb_tail).hexdigest())
print("headroom_before_AVB0", avb0 - used)
