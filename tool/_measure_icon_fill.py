from PIL import Image

paths = [
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png",
    "assets/branding/super_health_monogram_store.png",
    "assets/branding/_phone_home_final.png",
    "assets/branding/_phone_final_br1.png",
    "assets/branding/_phone_final_br2.png",
]


def content_bbox(im: Image.Image):
    rgba = im.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    min_x, min_y, max_x, max_y = w, h, -1, -1
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 20:
                continue
            # non-near-white
            if r < 245 or g < 245 or b < 245:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x < 0:
        return None
    bw, bh = max_x - min_x + 1, max_y - min_y + 1
    return min_x, min_y, max_x, max_y, bw / w, bh / h


for p in paths:
    try:
        im = Image.open(p)
    except Exception as e:
        print(p, "ERR", e)
        continue
    b = content_bbox(im)
    print(p, im.size, "content_frac", None if b is None else (round(b[4], 3), round(b[5], 3)))
