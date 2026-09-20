from PIL import Image

im = Image.open(r"assets/branding/_phone_home_final.png").convert("RGB")
w, h = im.size
px = im.load()
# Find clusters of saturated non-green pixels that look like the Google ring.
hits = []
for y in range(h):
    for x in range(w):
        r, g, b = px[x, y]
        # colorful saturated (not grass, not sky)
        mx, mn = max(r, g, b), min(r, g, b)
        if mx - mn < 80:
            continue
        if g > r + 40 and g > b + 40:
            continue  # grass
        if b > r + 40 and b > g + 30 and b > 150:
            continue  # sky-ish
        if mx > 180 and mn < 120:
            hits.append((x, y))

if not hits:
    print("no hits")
else:
    xs = [p[0] for p in hits]
    ys = [p[1] for p in hits]
    print("hits", len(hits), "bbox", min(xs), min(ys), max(xs), max(ys))
    # Expand to icon tile
    cx = (min(xs) + max(xs)) // 2
    cy = (min(ys) + max(ys)) // 2
    side = max(max(xs) - min(xs), max(ys) - min(ys)) + 40
    half = side // 2
    box = (
        max(0, cx - half),
        max(0, cy - half - 30),
        min(w, cx + half),
        min(h, cy + half + 50),
    )
    crop = im.crop(box)
    out = r"assets/branding/_phone_health_icon_now.png"
    crop.save(out)
    print("saved", out, crop.size, "box", box)
