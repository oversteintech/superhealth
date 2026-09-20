"""Apply approved Google-ring icon preview to all Super Health branding assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/branding/super_health_icon_preview_google_ring.png"

TARGETS = {
    ROOT / "assets/branding/super_health_monogram.png": 1024,
    ROOT / "assets/branding/super_health_monogram_store.png": 1024,
    ROOT / "assets/branding/super_health_monogram_foreground.png": 1024,
    ROOT / "assets/branding/super_health_premium_icon.png": 1024,
    ROOT / "assets/branding/super_app_icons/super_health_hd.png": 1920,
}


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"missing source: {SRC}")
    src = Image.open(SRC).convert("RGBA")
    # Flatten onto pure white (launcher / store safe).
    canvas = Image.new("RGBA", src.size, (255, 255, 255, 255))
    canvas.alpha_composite(src)
    for path, size in TARGETS.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        out = canvas.resize((size, size), Image.Resampling.LANCZOS)
        # Foreground keeps alpha channel but sits on white for adaptive inset 0.
        if path.name.endswith("_foreground.png"):
            out.save(path)
        else:
            out.convert("RGB").save(path, optimize=True)
        print(f"wrote {path.relative_to(ROOT)} ({size}x{size})")


if __name__ == "__main__":
    main()
