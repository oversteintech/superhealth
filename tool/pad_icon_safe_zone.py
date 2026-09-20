"""Shrink ring+EKG into safe zone so launcher masks don't clip."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/branding/super_health_icon_preview_google_ring.png"

# Content diameter as fraction of canvas (adaptive safe zone ~66–72%).
CONTENT_SCALE = 0.70

TARGETS = {
    ROOT / "assets/branding/super_health_monogram.png": 1024,
    ROOT / "assets/branding/super_health_monogram_store.png": 1024,
    ROOT / "assets/branding/super_health_monogram_foreground.png": 1024,
    ROOT / "assets/branding/super_health_premium_icon.png": 1024,
    ROOT / "assets/branding/super_app_icons/super_health_hd.png": 1920,
}


def padded(src: Image.Image, size: int) -> Image.Image:
    base = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    # Trim near-white margins from source so scale is based on real art.
    rgba = src.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    min_x, min_y, max_x, max_y = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 8:
                continue
            if r >= 250 and g >= 250 and b >= 250:
                continue
            min_x = min(min_x, x)
            min_y = min(min_y, y)
            max_x = max(max_x, x)
            max_y = max(max_y, y)
    if max_x <= min_x:
        art = rgba
    else:
        pad = 8
        art = rgba.crop(
            (
                max(0, min_x - pad),
                max(0, min_y - pad),
                min(w, max_x + 1 + pad),
                min(h, max_y + 1 + pad),
            )
        )
    target = int(size * CONTENT_SCALE)
    art = art.resize((target, target), Image.Resampling.LANCZOS)
    ox = (size - target) // 2
    oy = (size - target) // 2
    base.alpha_composite(art, (ox, oy))
    return base


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    for path, size in TARGETS.items():
        out = padded(src, size)
        if path.name.endswith("_foreground.png"):
            out.save(path)
        else:
            out.convert("RGB").save(path, optimize=True)
        print(f"wrote {path.name} scale={CONTENT_SCALE}")


if __name__ == "__main__":
    main()
