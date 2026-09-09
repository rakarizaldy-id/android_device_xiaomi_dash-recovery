#!/usr/bin/env python3
import hashlib
import sys
from pathlib import Path

REMOVE = {
    "system/etc/vintf/manifest/android.hardware.boot-service.mtk.xml":
        "0fa13e87fd880e6476624f1467cecaaab034afc27c8fd39d6ee535dcb8be7a00",
    "system/etc/vintf/manifest/android.hardware.health-service.example.xml":
        "25fe85c1947d8efa93b30c6dce65e830d92f87bb1035f0b837674f4f57873ae5",
}
FSTAB = "first_stage_ramdisk/fstab.mt6991"

def align4(n): return (n + 3) & ~3

def strip_avb(data: bytes):
    text = data.decode("utf-8")
    out, removed = [], []
    for lineno, line in enumerate(text.splitlines(keepends=True), 1):
        nl = "\n" if line.endswith("\n") else ""
        raw = line[:-1] if nl else line
        stripped = raw.lstrip()
        if not stripped or stripped.startswith("#"):
            out.append(line); continue
        parts = raw.split(None, 4)
        if len(parts) < 5:
            out.append(line); continue
        flags = parts[4].split(",")
        keep = []
        for tok in flags:
            if tok == "avb" or tok.startswith("avb=") or tok.startswith("avb_keys="):
                removed.append((lineno, tok))
            else:
                keep.append(tok)
        out.append(" ".join(parts[:4]) + " " + ",".join(keep) + nl)
    return "".join(out).encode(), removed

def patch(inp: Path, outp: Path, dry=False):
    src = inp.read_bytes(); out = bytearray(); pos = 0
    archive = 0; entries = 0; trailers = 0; removed_files = []; avb_removed = []
    fstab_seen = 0; fstab_before = fstab_after = None
    while pos < len(src):
        if src[pos:pos+6] not in (b"070701", b"070702"):
            nxts = [x for x in (src.find(b"070701", pos), src.find(b"070702", pos)) if x >= 0]
            if not nxts:
                out.extend(src[pos:]); pos = len(src); break
            nxt = min(nxts)
            out.extend(src[pos:nxt]); pos = nxt; archive += 1
        start = pos; magic = src[pos:pos+6]
        if pos + 110 > len(src): raise SystemExit(f"truncated header at {pos}")
        hdr = src[pos:pos+110]
        vals = [int(hdr[6+i*8:14+i*8], 16) for i in range(13)]
        filesize, namesize = vals[6], vals[11]
        name_start = pos + 110
        name_end = name_start + namesize
        if name_end > len(src): raise SystemExit(f"bad name size at {pos}")
        nameb = src[name_start:name_end]
        if not nameb.endswith(b"\0"): raise SystemExit(f"unterminated name at {pos}")
        name = nameb[:-1].decode("utf-8", "surrogateescape")
        data_start = align4(name_end)
        data_end = data_start + filesize
        entry_end = align4(data_end)
        if entry_end > len(src): raise SystemExit(f"bad data size for {name}")
        data = src[data_start:data_end]
        entries += 1
        if name == "TRAILER!!!":
            trailers += 1; out.extend(src[start:entry_end]); pos = entry_end; continue
        if name in REMOVE:
            got = hashlib.sha256(data).hexdigest()
            if got != REMOVE[name]: raise SystemExit(f"refusing non-ID303 prune {name}: {got}")
            removed_files.append((archive, name, got)); pos = entry_end; continue
        if name == FSTAB:
            fstab_seen += 1; fstab_before = hashlib.sha256(data).hexdigest()
            newdata, toks = strip_avb(data); avb_removed.extend(toks)
            fstab_after = hashlib.sha256(newdata).hexdigest()
            nh = bytearray(hdr)
            nh[54:62] = f"{len(newdata):08x}".encode()
            if magic == b"070702": nh[102:110] = f"{sum(newdata)&0xffffffff:08x}".encode()
            out.extend(nh); out.extend(src[name_start:data_start]); out.extend(newdata)
            out.extend(b"\0" * (align4(len(out)) - len(out)))
            pos = entry_end; continue
        out.extend(src[start:entry_end]); pos = entry_end
    print(f"ARCHIVES={archive}")
    print(f"TRAILERS={trailers}")
    print(f"ENTRIES={entries}")
    print(f"FSTAB_SEEN={fstab_seen}")
    print(f"FSTAB_SHA_BEFORE={fstab_before}")
    print(f"FSTAB_SHA_AFTER={fstab_after}")
    print(f"AVB_TOKENS_REMOVED={len(avb_removed)}")
    for ln,tok in avb_removed: print(f"AVB {ln}: {tok}")
    print(f"VINTF_FILES_REMOVED={len(removed_files)}")
    for a,n,h in removed_files: print(f"VINTF archive={a} sha256={h} {n}")
    if fstab_seen != 1: raise SystemExit(f"expected exactly one {FSTAB}, got {fstab_seen}")
    if len(avb_removed) != 23: raise SystemExit(f"expected 23 AVB tokens, got {len(avb_removed)}")
    if len(removed_files) != 2: raise SystemExit(f"expected 2 VINTF removals, got {len(removed_files)}")
    if not dry:
        outp.write_bytes(out)
        print(f"OUTPUT_SIZE={len(out)}")
        print(f"OUTPUT_SHA256={hashlib.sha256(out).hexdigest()}")

if len(sys.argv) not in (2,3):
    raise SystemExit(f"usage: {sys.argv[0]} INPUT_CPIO [OUTPUT_CPIO]")
inp=Path(sys.argv[1]); outp=Path(sys.argv[2]) if len(sys.argv)==3 else Path("/dev/null")
patch(inp,outp,dry=(len(sys.argv)==2))
