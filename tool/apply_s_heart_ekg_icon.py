"""Apply approved metallic S + anatomical heart + EKG icon to branding assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

SRC_CANDIDATES = [
    Path(
        r"C:\Users\ayhan\.cursor\projects\c-Users-ayhan-StudioProjects-superhealth\assets"
        r"\c__Users_ayhan_AppData_Roaming_Cursor_User_workspaceStorage_"
        r"3b2940c54ee5411f72e3f21682a1b569_images_Codex_G_rseli_23_Eyl_2026_"
        r"20_17_43-3e8c1316-50b6-4b50-81f1-c3eec42c7284.jpg"
    ),
]

OUT_PREVIEW = ROOT / "assets/branding/super_health_icon_approved_preview.png"
OUT_PROPOSAL = (
    ROOT / "assets/branding/proposals/super_health_option_S_heart_ekg.png"
)

TARGETS = {
    ROOT / "assets/branding/super_health_monogram.png": 1024,
    ROOT / "assets/branding/super_health_monogram_store.png": 1024,
    ROOT / "assets/branding/super_health_monogram_foreground.png": 1024,
    ROOT / "assets/branding/super_health_premium_icon.png": 1024,
    ROOT / "assets/branding/super_app_icons/super_health_hd.png": 1920,
}

# Safe-zone scale so Android adaptive masks don't clip the S/heart.
# 0.84 was a touch small on home screen; +2 ticks (~0.03 each).
CONTENT_SCALE = 0.90


def resolve_src() -> Path:
    for path in SRC_CANDIDATES:
        if path.exists():
            return path
    assets = Path(
        r"C:\Users\ayhan\.cursor\projects\c-Users-ayhan-StudioProjects-superhealth\assets"
    )
    matches = sorted(assets.glob("*Codex_G_rseli*3e8c1316*"))
    if matches:
        return matches[0]
    raise SystemExit("source logo image not found")


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
    src_path = resolve_src()
    print("src", src_path)
    src = Image.open(src_path).convert("RGBA")
    OUT_PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    OUT_PROPOSAL.parent.mkdir(parents=True, exist_ok=True)

    master = src.resize((1024, 1024), Image.Resampling.LANCZOS)
    master.convert("RGB").save(OUT_PREVIEW, quality=95)
    master.convert("RGB").save(OUT_PROPOSAL, quality=95)

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
