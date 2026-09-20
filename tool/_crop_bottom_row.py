from PIL import Image

im = Image.open(r"assets/branding/_phone_page_health.png").convert("RGB")
w, h = im.size
# Bottom grid row icons roughly y=1550..1750 on 2440 height from earlier.
# 4 columns: x centers ~135, 405, 675, 945
row_y0, row_y1 = 1480, 1780
cols = [(40, 280), (310, 550), (580, 820), (850, 1070)]
for i, (x0, x1) in enumerate(cols):
    c = im.crop((x0, row_y0, x1, row_y1))
    path = rf"assets/branding/_phone_row_icon_{i}.png"
    c.save(path)
    # count colorful pixels
    px = c.load()
    cw, ch = c.size
    colorful = 0
    for y in range(ch):
        for x in range(cw):
            r, g, b = px[x, y]
            if max(r, g, b) - min(r, g, b) > 90 and not (g > r + 30 and g > b + 30):
                colorful += 1
    print(i, path, "colorful", colorful)

# also save bottom strip
im.crop((0, 1400, w, 1900)).save(r"assets/branding/_phone_bottom_strip.png")
print("strip saved", w, h)
