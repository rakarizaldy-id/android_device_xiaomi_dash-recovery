#!/usr/bin/env bash
set -euo pipefail
TOP="${1:-$PWD}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
P="$ROOT/patches"

check_head() {
    local repo="$1" expected="$2" actual
    actual="$(git -C "$TOP/$repo" rev-parse HEAD)"
    [[ "$actual" == "$expected" ]] || {
        echo "HEAD mismatch: $repo" >&2
        echo "expected=$expected" >&2
        echo "actual=$actual" >&2
        exit 2
    }
}

apply_one() {
    git -C "$TOP/$1" apply "$P/$2"
}

check_head bootable/recovery 62ce834eef4b26d50969eebfb0b042c6b3b531c7
check_head vendor/recovery 581bb9d8e5d247121fa3daeb2244d49c602720ac
check_head system/vold a164ba05c5fef288059774a776b2e6e1119957cf
check_head system/core ac4f36c7eb076ea2c582061a21dfc49eaa71e623
check_head build/make 1b692e2248609f50a27c48cce53b7445cecdcfc5
check_head system/update_engine f2b67e0969b5c527293e67b364aedce9347272be
check_head vendor/twrp 664ac3aa7a569d28d902734c741a629a59bab32d

apply_one bootable/recovery bootable-recovery.patch
apply_one vendor/recovery vendor-recovery.patch
apply_one system/vold system-vold.patch
apply_one system/core system-core.patch
apply_one build/make build-make.patch
apply_one system/update_engine system-update-engine.patch
apply_one vendor/twrp vendor-twrp.patch
