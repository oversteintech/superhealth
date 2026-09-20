"""Extract SuperHealth tile from family gallery and apply to all branding assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
GALLERY = Path(
    r"C:\Users\ayhan\.cursor\projects\c-Users-ayhan-StudioProjects-superhealth\assets"
    r"\c__Users_ayhan_AppData_Roaming_Cursor_User_workspaceStorage_"
    r"3b2940c54ee5411f72e3f21682a1b569_images_CLEAN_NO_STAIRS_GALLERY-"
    r"24bdb6b1-bc3f-4f7a-8022-28d38fbcc43d.jpg"
)

# Fallback if agent-assets path differs
if not GALLERY.exists():
    alt = list(
        Path(r"C:\Users\ayhan\.cursor\projects\c-Users-ayhan-StudioProjects-superhealth\assets").glob(
            "*CLEAN_NO_STAIRS_GALLERY*"
        )
    )
    if not alt:
        raise SystemExit("gallery image not found")
    GALLERY = alt[0]

OUT_PREVIEW = ROOT / "assets/branding/super_health_icon_approved_preview.png"
TARGETS = {
    ROOT / "assets/branding/super_health_monogram.png": 1024,
    ROOT / "assets/branding/super_health_monogram_store.png": 1024,
    ROOT / "assets/branding/super_health_monogram_foreground.png": 1024,
    ROOT / "assets/branding/super_health_premium_icon.png": 1024,
    ROOT / "assets/branding/super_app_icons/super_health_hd.png": 1920,
}

# Safe-zone scale for launcher masks (content diameter / canvas).
CONTENT_SCALE = 0.78


def extract_super_health(gallery: Image.Image) -> Image.Image:
    """Crop middle-row leftmost cell (SuperHealth) from 3x3 titled grid."""
    w, h = gallery.size
    # Grid of 3 cols x 3 rows; each cell has title above icon.
    # Empirically: equal thirds with small outer margin.
    margin_x = int(w * 0.02)
    margin_y = int(h * 0.02)
    cell_w = (w - 2 * margin_x) // 3
    cell_h = (h - 2 * margin_y) // 3
    col, row = 0, 1  # SuperHealth
    x0 = margin_x + col * cell_w
    y0 = margin_y + row * cell_h
    # Drop title band (~12% of cell height) keep icon plate.
    title_cut = int(cell_h * 0.14)
    box = (
        x0 + int(cell_w * 0.04),
        y0 + title_cut,
        x0 + cell_w - int(cell_w * 0.04),
        y0 + cell_h - int(cell_h * 0.03),
    )
    tile = gallery.crop(box)
    # Make square by center-crop on the shorter side.
    tw, th = tile.size
    side = min(tw, th)
    left = (tw - side) // 2
    top = (th - side) // 2
    return tile.crop((left, top, left + side, top + side))


def fit_safe(src: Image.Image, size: int) -> Image.Image:
    # Sample corner color for background (peach plate).
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
    gallery = Image.open(GALLERY).convert("RGBA")
    print("gallery", gallery.size, GALLERY.name)
    tile = extract_super_health(gallery)
    OUT_PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    tile.resize((1024, 1024), Image.Resampling.LANCZOS).convert("RGB").save(
        OUT_PREVIEW, quality=95
    )
    print("preview", OUT_PREVIEW)

    for path, size in TARGETS.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        out = fit_safe(tile, size)
        if path.name.endswith("_foreground.png"):
            out.save(path)
        else:
            out.convert("RGB").save(path, quality=95)
        print("wrote", path.name, size)


if __name__ == "__main__":
    main()
