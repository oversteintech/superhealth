"""Replace launcher icons inside existing debug APK and resign."""

from __future__ import annotations

import shutil
import subprocess
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APK_SRC = ROOT / "build/app/outputs/flutter-apk/app-debug.apk"
APK_OUT = ROOT / "build/app/outputs/flutter-apk/app-debug-heart.apk"
RES = ROOT / "android/app/src/main/res"
KEYSTORE = Path.home() / ".android/debug.keystore"

# APK paths commonly used by Flutter debug builds.
ICON_MAP = [
    ("res/mipmap-mdpi-v4/ic_launcher.png", RES / "mipmap-mdpi/ic_launcher.png"),
    ("res/mipmap-hdpi-v4/ic_launcher.png", RES / "mipmap-hdpi/ic_launcher.png"),
    ("res/mipmap-xhdpi-v4/ic_launcher.png", RES / "mipmap-xhdpi/ic_launcher.png"),
    ("res/mipmap-xxhdpi-v4/ic_launcher.png", RES / "mipmap-xxhdpi/ic_launcher.png"),
    ("res/mipmap-xxxhdpi-v4/ic_launcher.png", RES / "mipmap-xxxhdpi/ic_launcher.png"),
    ("res/mipmap-mdpi-v4/ic_launcher_white.png", RES / "mipmap-mdpi/ic_launcher_white.png"),
    ("res/mipmap-hdpi-v4/ic_launcher_white.png", RES / "mipmap-hdpi/ic_launcher_white.png"),
    ("res/mipmap-xhdpi-v4/ic_launcher_white.png", RES / "mipmap-xhdpi/ic_launcher_white.png"),
    ("res/mipmap-xxhdpi-v4/ic_launcher_white.png", RES / "mipmap-xxhdpi/ic_launcher_white.png"),
    ("res/mipmap-xxxhdpi-v4/ic_launcher_white.png", RES / "mipmap-xxxhdpi/ic_launcher_white.png"),
    ("res/drawable-mdpi-v4/ic_launcher_foreground.png", RES / "drawable-mdpi/ic_launcher_foreground.png"),
    ("res/drawable-hdpi-v4/ic_launcher_foreground.png", RES / "drawable-hdpi/ic_launcher_foreground.png"),
    ("res/drawable-xhdpi-v4/ic_launcher_foreground.png", RES / "drawable-xhdpi/ic_launcher_foreground.png"),
    ("res/drawable-xxhdpi-v4/ic_launcher_foreground.png", RES / "drawable-xxhdpi/ic_launcher_foreground.png"),
    ("res/drawable-xxxhdpi-v4/ic_launcher_foreground.png", RES / "drawable-xxxhdpi/ic_launcher_foreground.png"),
]


def find_apksigner() -> Path | None:
    sdk = Path.home() / "AppData/Local/Android/Sdk/build-tools"
    if not sdk.exists():
        return None
    versions = sorted(sdk.iterdir(), reverse=True)
    for v in versions:
        p = v / "apksigner.bat"
        if p.exists():
            return p
    return None


def main() -> None:
    if not APK_SRC.exists():
        raise SystemExit(f"missing {APK_SRC}")
    if not KEYSTORE.exists():
        raise SystemExit(f"missing debug keystore {KEYSTORE}")

    # Discover actual zip entry names for icons.
    with zipfile.ZipFile(APK_SRC, "r") as zin:
        names = set(zin.namelist())
    replacements: dict[str, Path] = {}
    for apk_path, disk in ICON_MAP:
        if not disk.exists():
            continue
        # Try with and without -v4 suffix.
        candidates = [
            apk_path,
            apk_path.replace("-v4/", "/"),
            apk_path.replace("mipmap-", "mipmap-").replace("-v4", ""),
        ]
        for c in candidates:
            if c in names:
                replacements[c] = disk
                break
        else:
            # Fuzzy search by basename + density folder hint.
            base = disk.name
            density = disk.parent.name  # mipmap-xxhdpi / drawable-xxhdpi
            for n in names:
                if n.endswith("/" + base) and density.split("-")[-1] in n:
                    replacements[n] = disk
                    break

    print("replacements", len(replacements))
    for k, v in sorted(replacements.items()):
        print(" ", k, "<-", v.name)

    if APK_OUT.exists():
        APK_OUT.unlink()

    with zipfile.ZipFile(APK_SRC, "r") as zin, zipfile.ZipFile(
        APK_OUT, "w", compression=zipfile.ZIP_DEFLATED
    ) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename in replacements:
                data = replacements[item.filename].read_bytes()
            # Drop old signature so we can resign.
            if item.filename.startswith("META-INF/"):
                continue
            zout.writestr(item, data)

    apksigner = find_apksigner()
    if apksigner is None:
        raise SystemExit("apksigner not found")
    cmd = [
        str(apksigner),
        "sign",
        "--ks",
        str(KEYSTORE),
        "--ks-key-alias",
        "androiddebugkey",
        "--ks-pass",
        "pass:android",
        "--key-pass",
        "pass:android",
        "--out",
        str(APK_OUT),
        str(APK_OUT),
    ]
    # apksigner --out same file may need temp; use inplace sign
    cmd = [
        str(apksigner),
        "sign",
        "--ks",
        str(KEYSTORE),
        "--ks-key-alias",
        "androiddebugkey",
        "--ks-pass",
        "pass:android",
        "--key-pass",
        "pass:android",
        str(APK_OUT),
    ]
    subprocess.check_call(cmd)
    print("signed", APK_OUT, APK_OUT.stat().st_size)


if __name__ == "__main__":
    main()
