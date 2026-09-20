"""Write SuperCore SVG that embeds the approved SuperHealth PNG as JPEG."""

from __future__ import annotations

import base64
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/branding/super_health_monogram_store.png"
SVG = (
    ROOT.parent
    / "supercore/packages/after_design_system/assets/branding/super_app_icons/super_health.svg"
)


def main() -> None:
    im = Image.open(SRC).convert("RGB").resize((768, 768), Image.Resampling.LANCZOS)
    buf = BytesIO()
    im.save(buf, format="JPEG", quality=88, optimize=True)
    b64 = base64.b64encode(buf.getvalue()).decode("ascii")
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" role="img" aria-label="Super Health">
  <image href="data:image/jpeg;base64,{b64}" x="0" y="0" width="1024" height="1024" preserveAspectRatio="xMidYMid meet"/>
</svg>
"""
    SVG.write_text(svg, encoding="utf-8")
    print("wrote", SVG, "bytes", SVG.stat().st_size)


if __name__ == "__main__":
    main()
