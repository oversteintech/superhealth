from PIL import Image
from pathlib import Path

im = Image.open(r"assets/branding/_phone_page_health.png").convert("RGB")
w, h = im.size
px = im.load()

# Score each 220x220 window for: white plate + colorful ring + red ekg
best = None
step = 40
win = 220
for y in range(400, h - 400, step):
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
                if chroma > 100 and not (g > r + 40 and g > b + 40):
                    colorful += 1
                if r > 180 and r > g + 40 and r > b + 40:
                    redish += 1
        # Health: decent white, colorful ring, red ekg
        score = 0
        if white > total * 0.25:
            score += white
        score += colorful * 2
        score += redish * 5
        if colorful > 80 and redish > 15 and white > 100:
            if best is None or score > best[0]:
                best = (score, x, y, white, colorful, redish)

print("best", best)
if best:
    _, x, y, *_ = best
    box = (x - 20, y - 20, x + win + 20, y + win + 60)
    box = (max(0, box[0]), max(0, box[1]), min(w, box[2]), min(h, box[3]))
    crop = im.crop(box)
    out = Path(r"assets/branding/_phone_health_found.png")
    crop.save(out)
    print("saved", out, box)
