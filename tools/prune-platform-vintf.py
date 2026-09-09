#!/usr/bin/env python3
import hashlib
import sys
from pathlib import Path

EXPECTED = {
    "system/etc/vintf/manifest/android.hardware.boot-service.mtk.xml":
        "0fa13e87fd880e6476624f1467cecaaab034afc27c8fd39d6ee535dcb8be7a00",
    "system/etc/vintf/manifest/android.hardware.health-service.example.xml":
        "25fe85c1947d8efa93b30c6dce65e830d92f87bb1035f0b837674f4f57873ae5",
}
if len(sys.argv) != 2:
    raise SystemExit(f"usage: {sys.argv[0]} PLATFORM_ROOT")
root = Path(sys.argv[1]).resolve()
removed = []
for rel, expected in EXPECTED.items():
    p = root / rel
    if not p.is_file():
        raise SystemExit(f"missing expected ID303 PLATFORM file: {rel}")
    got = hashlib.sha256(p.read_bytes()).hexdigest()
    if got != expected:
        raise SystemExit(f"refusing to prune non-ID303 file: {rel} sha256={got}")
    p.unlink()
    removed.append(rel)
print(f"PLATFORM_VINTF_PRUNED={len(removed)}")
for rel in removed:
    print(rel)
