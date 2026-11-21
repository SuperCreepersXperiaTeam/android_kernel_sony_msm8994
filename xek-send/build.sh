#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PATCH_DIR="$ROOT/xek-send/patches"
OUT="$ROOT/out"
mkdir -p "$OUT"

echo "== Verificando árbol kernel =="
test -f Makefile
grep -q '^VERSION = 3$' Makefile
grep -q '^PATCHLEVEL = 10$' Makefile
grep -q '^SUBLEVEL = 108$' Makefile
test -f arch/arm64/configs/kitakami_sumire_defconfig
test -f arch/arm/boot/dts/qcom/batterydata-kitakami-sumire-send.dtsi
test -f drivers/power/qpnp-fg.c

echo "== Comprobando que ambos parches aplican sin conflictos =="
patch --batch --forward --dry-run -p1 < "$PATCH_DIR/0001-sumire-send-id-match.patch"
patch --batch --forward --dry-run -p1 < "$PATCH_DIR/0002-fg-compare-full-profile.patch"

echo "== Aplicando ambos parches =="
patch --batch --forward -p1 < "$PATCH_DIR/0001-sumire-send-id-match.patch"
patch --batch --forward -p1 < "$PATCH_DIR/0002-fg-compare-full-profile.patch"

echo "== Verificando cambios exactos =="
grep -Fq 'qcom,batt-id-kohm = <492>' arch/arm/boot/dts/qcom/batterydata-kitakami-sumire-send.dtsi
grep -Eq '^#define PROFILE_COMPARE_LEN[[:space:]]+FG_PROFILE_LEN$' drivers/power/qpnp-fg.c
git diff --check

echo "== Compilando Image.gz-dtb para sumire =="
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- kitakami_sumire_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" Image.gz-dtb

IMAGE="arch/arm64/boot/Image.gz-dtb"
test -s "$IMAGE"
cp "$IMAGE" "$OUT/Image.gz-dtb"
cp .config "$OUT/kernel.config"
cp System.map "$OUT/System.map"
git diff --check
git diff --binary > "$OUT/send-source-diff.patch"
sha256sum "$OUT/"* > "$OUT/SHA256SUMS.txt"
{
  echo "Kernel: $(git rev-parse HEAD)"
  echo "Branch/ref: $(git branch --show-current || true)"
  echo "Config: kitakami_sumire_defconfig"
  echo "Image: Image.gz-dtb"
  echo "SEND batt-id-kohm: 492"
  echo "Profile compare length: FG_PROFILE_LEN (128)"
  echo "NOTE: kernel image only; not a boot.img or TWRP installer."
} > "$OUT/BUILD_INFO.txt"
echo "BUILD_OK: $OUT/Image.gz-dtb"
