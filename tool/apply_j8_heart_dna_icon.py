"""Apply approved J8 heart+DNA icon to all Super Health branding assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/branding/proposals/super_health_option_J8_heart_dna.png"
OUT_PREVIEW = ROOT / "assets/branding/super_health_icon_approved_preview.png"

TARGETS = {
    ROOT / "assets/branding/super_health_monogram.png": 1024,
    ROOT / "assets/branding/super_health_monogram_store.png": 1024,
    ROOT / "assets/branding/super_health_monogram_foreground.png": 1024,
    ROOT / "assets/branding/super_health_premium_icon.png": 1024,
    ROOT / "assets/branding/super_app_icons/super_health_hd.png": 1920,
}

CONTENT_SCALE = 0.82


def fit_safe(src: Image.Image, size: int) -> Image.Image:
    rgba = src.convert("RGBA")
    corner = rgba.getpixel((8, 8))
    bg = (corner[0], corner[1], corner[2], 255)
    canvas = Image.new("RGBA", (size, size), bg)
    target = int(size * CONTENT_SCALE)
    art = rgba.resize((target, target), Image.Resampling.LANCZOS)
    ox = (size - target) // 2
    oy = (size - target) // 2
    canvas.alpha_composite(art, (ox, oy))
    return canvas


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"missing {SRC}")
    src = Image.open(SRC).convert("RGBA")
    OUT_PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    src.resize((1024, 1024), Image.Resampling.LANCZOS).convert("RGB").save(
        OUT_PREVIEW, quality=95
    )
    r, g, b = src.convert("RGB").getpixel((20, 20))
    print(f"bg #{r:02X}{g:02X}{b:02X}")
    for path, size in TARGETS.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        out = fit_safe(src, size)
        if path.name.endswith("_foreground.png"):
            out.save(path)
        else:
            out.convert("RGB").save(path, quality=95)
        print("wrote", path.name, size)


if __name__ == "__main__":
    main()
