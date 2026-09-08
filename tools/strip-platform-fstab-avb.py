#!/usr/bin/env python3
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit(f"usage: {sys.argv[0]} INPUT_FSTAB OUTPUT_FSTAB")
src, dst = map(Path, sys.argv[1:])
out = []
removed = []
for lineno, line in enumerate(src.read_text().splitlines(keepends=True), 1):
    raw = line.rstrip('\n')
    nl = '\n' if line.endswith('\n') else ''
    stripped = raw.lstrip()
    if not stripped or stripped.startswith('#'):
        out.append(line)
        continue
    parts = raw.split(None, 4)
    if len(parts) < 5:
        out.append(line)
        continue
    flags = parts[4].split(',')
    keep = []
    for token in flags:
        if token == 'avb' or token.startswith('avb=') or token.startswith('avb_keys='):
            removed.append((lineno, token))
        else:
            keep.append(token)
    prefix = ' '.join(parts[:4])
    out.append(prefix + ' ' + ','.join(keep) + nl)
dst.write_text(''.join(out))
print(f'AVB_TOKENS_REMOVED={len(removed)}')
for lineno, token in removed:
    print(f'{lineno}: {token}')
