from pathlib import Path

from PIL import Image

# Prefer the known page that previously had Health next to Tatilbudur.
candidates = [
    Path("assets/branding/_phone_health_page_now.png"),
    Path("assets/branding/_phone_home_p2.png"),
    Path("assets/branding/_scan_p2.png"),
    Path("assets/branding/_scan_p1.png"),
    Path("assets/branding/_phone_home_after.png"),
]

# Bottom-right grid cell where Health sat before (4-col layout).
boxes = [
    (820, 1520, 1060, 1820),
    (800, 1480, 1070, 1780),
    (780, 1550, 1050, 1850),
]


def score_health(im: Image.Image) -> int:
    px = im.convert("RGB").load()
    w, h = im.size
    white = colorful = redish = 0
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = px[x, y]
            if r > 230 and g > 230 and b > 230:
                white += 1
            chroma = max(r, g, b) - min(r, g, b)
            if chroma > 100 and not (g > r + 40 and g > b + 40):
                colorful += 1
            if r > 190 and r > g + 50 and r > b + 50:
                redish += 1
    # Prefer white plate + ring colors + ekg red; reject solid-red icons.
    if white < 200:
        return -1
    if redish > colorful:
        return -1
    return colorful * 2 + redish * 3 + white


best = None
for path in candidates:
    if not path.exists():
        continue
    full = Image.open(path)
    for i, box in enumerate(boxes):
        crop = full.crop(box)
        s = score_health(crop)
        print(path.name, i, s)
        if s > 0 and (best is None or s > best[0]):
            best = (s, path, box, crop)

if best is None:
    raise SystemExit("Health crop not found")

s, path, box, crop = best
out = Path("assets/branding/_phone_health_verified.png")
crop.save(out)
print("saved", out, "from", path.name, "score", s, "box", box)
