from pathlib import Path

from PIL import Image

pages = sorted(Path("assets/branding").glob("_scan_p*.png"))
best_global = None

for page in pages:
    im = Image.open(page).convert("RGB")
    w, h = im.size
    px = im.load()
    best = None
    step = 30
    win = 200
    for y in range(350, h - 350, step):
        for x in range(0, w - win, step):
            white = colorful = redish = 0
            total = 0
            for yy in range(y, y + win, 2):
                for xx in range(x, x + win, 2):
                    r, g, b = px[xx, yy]
                    total += 1
                    if r > 230 and g > 230 and b > 230:
                        white += 1
                    chroma = max(r, g, b) - min(r, g, b)
                    if chroma > 110 and not (g > r + 40 and g > b + 40):
                        colorful += 1
                    if r > 190 and r > g + 50 and r > b + 50:
                        redish += 1
            if colorful > 120 and redish > 25 and white > 80:
                score = colorful * 2 + redish * 8 + white
                if best is None or score > best[0]:
                    best = (score, x, y, white, colorful, redish)
    print(page.name, "best", best)
    if best and (best_global is None or best[0] > best_global[0]):
        best_global = (best[0], page, best[1], best[2], best[3], best[4], best[5])

if best_global:
    score, page, x, y, white, colorful, redish = best_global
    im = Image.open(page)
    win = 200
    box = (max(0, x - 30), max(0, y - 30), min(im.size[0], x + win + 30), min(im.size[1], y + win + 70))
    crop = im.crop(box)
    out = Path("assets/branding/_phone_health_verified.png")
    crop.save(out)
    print("VERIFIED", out, "from", page.name, "score", score, "box", box)
else:
    print("NOT FOUND")
