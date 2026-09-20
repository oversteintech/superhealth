from PIL import Image

src = r"assets/branding/_phone_home_final.png"
im = Image.open(src)
w, h = im.size
print("full", w, h)
# Swipe may have changed page — scan for colorful ring by sampling.
# Try multiple regions where Health usually sits.
boxes = [
    ("br1", (780, 1550, 1050, 1850)),
    ("br2", (800, 1480, 1070, 1780)),
    ("br3", (750, 1400, 1080, 1720)),
    ("full_lower", (0, 1200, 1080, 2000)),
]
for name, box in boxes:
    c = im.crop(box)
    path = rf"assets/branding/_phone_final_{name}.png"
    c.save(path)
    print(name, c.size)
