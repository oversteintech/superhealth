"""Grey/silver → black. Keep large white regions + red EKG; drop tiny white speculars."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
TARGETS = [
    ROOT / "assets/branding/super_health_monogram.png",
    ROOT / "assets/branding/super_health_monogram_store.png",
    ROOT / "assets/branding/super_health_monogram_foreground.png",
    ROOT / "assets/branding/super_health_premium_icon.png",
    ROOT / "assets/branding/super_app_icons/super_health_hd.png",
]

# Specular blobs are tiny; plate / ring-hole whites are huge.
MIN_WHITE_COMPONENT = 800


def is_red(r: int, g: int, b: int) -> bool:
    if r < 85:
        return False
    if r >= g + 18 and r >= b + 18:
        return True
    return r >= 195 and min(g, b) >= 105 and r - min(g, b) >= 18


def is_whiteish(r: int, g: int, b: int, a: int) -> bool:
    # Strict: only flat paper-white, not silver specular (#E6E6E6 etc.).
    return a >= 250 and min(r, g, b) >= 250 and (max(r, g, b) - min(r, g, b)) <= 8


def white_keep_mask(img: Image.Image, min_component: int) -> set[tuple[int, int]]:
    w, h = img.size
    px = img.load()
    visited = [[False] * w for _ in range(h)]
    keep: set[tuple[int, int]] = set()

    for y in range(h):
        for x in range(w):
            if visited[y][x]:
                continue
            r, g, b, a = px[x, y]
            if not is_whiteish(r, g, b, a):
                visited[y][x] = True
                continue
            comp: list[tuple[int, int]] = []
            q: deque[tuple[int, int]] = deque([(x, y)])
            visited[y][x] = True
            while q:
                cx, cy = q.popleft()
                comp.append((cx, cy))
                for nx, ny in (
                    (cx - 1, cy),
                    (cx + 1, cy),
                    (cx, cy - 1),
                    (cx, cy + 1),
                ):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h or visited[ny][nx]:
                        continue
                    nr, ng, nb, na = px[nx, ny]
                    if is_whiteish(nr, ng, nb, na):
                        visited[ny][nx] = True
                        q.append((nx, ny))
            if len(comp) >= min_component:
                keep.update(comp)
    return keep


def recolor(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    px = img.load()
    w, h = img.size
    min_comp = max(MIN_WHITE_COMPONENT, (w * h) // 2000)
    keep_white = white_keep_mask(img, min_comp)
    if len(keep_white) < min_comp:
        raise SystemExit(f"{path.name}: white keep mask too small ({len(keep_white)})")

    changed = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if is_red(r, g, b):
                continue
            if (x, y) in keep_white:
                if (r, g, b) != (255, 255, 255):
                    px[x, y] = (255, 255, 255, 255)
                    changed += 1
                continue
            # AA fringe beside kept white → white.
            if min(r, g, b) >= 235 and (max(r, g, b) - min(r, g, b)) <= 12:
                if (
                    (x - 1, y) in keep_white
                    or (x + 1, y) in keep_white
                    or (x, y - 1) in keep_white
                    or (x, y + 1) in keep_white
                ):
                    px[x, y] = (255, 255, 255, 255)
                    changed += 1
                    continue
            if (r, g, b) != (0, 0, 0):
                px[x, y] = (0, 0, 0, a)
                changed += 1
    img.save(path)
    print(f"{path.name}: keep_white={len(keep_white)} changed={changed} ({w}x{h})")


def main() -> None:
    for path in TARGETS:
        if not path.exists():
            print(f"skip missing: {path}")
            continue
        recolor(path)


if __name__ == "__main__":
    main()
