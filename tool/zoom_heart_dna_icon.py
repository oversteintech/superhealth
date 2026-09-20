"""Zoom in on heart+DNA icon while keeping the same heart symbol."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/branding/proposals/super_health_option_J8_heart_dna_v3.png"
OUT = ROOT / "assets/branding/proposals/super_health_option_J8_heart_dna_v5_zoom_out.png"

# Two ticks out from v4 (was 0.14): each tick ≈ 0.04
CROP_FRAC = 0.06


def main() -> None:
    im = Image.open(SRC).convert("RGBA")
    w, h = im.size
    dx = int(w * CROP_FRAC)
    dy = int(h * CROP_FRAC)
    cropped = im.crop((dx, dy, w - dx, h - dy))
    # Sample near-edge bg after crop for padding fill if needed when squaring.
    out = cropped.resize((1024, 1024), Image.Resampling.LANCZOS)
    out.convert("RGB").save(OUT, quality=95)
    # Also become the source for apply script.
    apply_src = ROOT / "assets/branding/proposals/super_health_option_J8_heart_dna.png"
    out.convert("RGB").save(apply_src, quality=95)
    print("wrote", OUT.name, "crop", CROP_FRAC)


if __name__ == "__main__":
    main()
