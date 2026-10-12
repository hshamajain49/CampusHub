"""Generates every CampusHub brand asset from one geometric definition.

The mark is a "C" ring (Campus + the "hub" that connects everything) wrapped
around a mortarboard, drawn in white on a navy -> teal gradient tile.

Outputs (in assets/branding/):
  logo.svg                  vector source of the full tile logo
  logo.png                  in-app logo tile (used by AppLogo / splash page)
  icon_ios.png              full-bleed square icon (iOS, macOS, web, Windows)
  icon_android_legacy.png   rounded tile for pre-Oreo Android launchers
  icon_foreground.png       adaptive icon foreground (mark inside safe zone)
  icon_background.png       adaptive icon background (gradient)
  icon_monochrome.png       Android 13+ themed icon
  splash_logo.png           native launch screen image (4x density)
  splash_android12.png      Android 12+ system splash icon

Usage (from the project root):
  python tool/generate_brand_assets.py
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
"""

from __future__ import annotations

import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")

# Brand palette (keep in sync with lib/core/theme/app_colors.dart).
NAVY = (0x1E, 0x3A, 0x8A)
TEAL = (0x0D, 0x94, 0x88)
WHITE = (255, 255, 255)

SS = 4  # supersampling factor for anti-aliasing
TILE_RADIUS = 0.225  # corner radius as a fraction of tile size
MARK_IN_TILE = 0.64  # mark diameter as a fraction of tile size

# ---------------------------------------------------------------------------
# Mark geometry, in "mark space": centred on (0, 0), ring outer radius = 0.5,
# y grows downwards (same as image space).
# ---------------------------------------------------------------------------
RING_WIDTH = 0.125
RING_GAP_DEG = 42  # half-angle of the opening on the right-hand side
NODE_RADIUS = 0.095  # the round "hub nodes" at each end of the C

DIAMOND = [(-0.295, -0.075), (0.0, -0.21), (0.295, -0.075), (0.0, 0.06)]

TASSEL_X = 0.295
TASSEL_TOP = -0.075
TASSEL_BOTTOM = 0.12
TASSEL_WIDTH = 0.036
TASSEL_KNOB = (0.052, 0.07)  # (width, height)


def _band_points(steps: int = 24) -> list[tuple[float, float]]:
    """Cap band under the board: a chevron top edge with a curved bottom."""
    gap = 0.05
    half = 0.178
    slope = (DIAMOND[3][1] - DIAMOND[0][1]) / (DIAMOND[3][0] - DIAMOND[0][0])

    def top_y(x: float) -> float:
        # Follows the diamond's lower edges, offset down by `gap`.
        return DIAMOND[3][1] - slope * abs(x) + gap

    side_bottom = 0.175
    bulge = 0.055
    pts = [(-half, top_y(-half)), (0.0, top_y(0.0)), (half, top_y(half))]
    pts.append((half, side_bottom))
    for i in range(1, steps):
        x = half - (2 * half) * i / steps
        y = side_bottom + bulge * (1 - (x / half) ** 2)
        pts.append((x, y))
    pts.append((-half, side_bottom))
    return pts


BAND = _band_points()


def _ring_end(angle_deg: float) -> tuple[float, float]:
    r = 0.5 - RING_WIDTH / 2
    a = math.radians(angle_deg)
    return (r * math.cos(a), r * math.sin(a))


# ---------------------------------------------------------------------------
# Raster drawing
# ---------------------------------------------------------------------------
def draw_mark(img: Image.Image, cx: float, cy: float, size: float, fill) -> None:
    """Draws the mark onto `img` (already supersampled), centred at (cx, cy)."""
    d = ImageDraw.Draw(img)

    def p(x: float, y: float) -> tuple[float, float]:
        return (cx + x * size, cy + y * size)

    # The "C" ring. PIL angles run clockwise from 3 o'clock; width grows inward.
    outer = 0.5 * size
    d.arc(
        [cx - outer, cy - outer, cx + outer, cy + outer],
        start=RING_GAP_DEG,
        end=360 - RING_GAP_DEG,
        fill=fill,
        width=round(RING_WIDTH * size),
    )
    for ang in (RING_GAP_DEG, -RING_GAP_DEG):
        nx, ny = p(*_ring_end(ang))
        r = NODE_RADIUS * size
        d.ellipse([nx - r, ny - r, nx + r, ny + r], fill=fill)

    # Mortarboard.
    d.polygon([p(x, y) for x, y in DIAMOND], fill=fill)
    d.polygon([p(x, y) for x, y in BAND], fill=fill)

    # Tassel.
    tx0, ty0 = p(TASSEL_X - TASSEL_WIDTH / 2, TASSEL_TOP)
    tx1, ty1 = p(TASSEL_X + TASSEL_WIDTH / 2, TASSEL_BOTTOM)
    d.rectangle([tx0, ty0, tx1, ty1], fill=fill)
    kw, kh = TASSEL_KNOB
    kx0, ky0 = p(TASSEL_X - kw / 2, TASSEL_BOTTOM - 0.01)
    kx1, ky1 = p(TASSEL_X + kw / 2, TASSEL_BOTTOM - 0.01 + kh)
    d.rounded_rectangle([kx0, ky0, kx1, ky1], radius=kw * size / 2.2, fill=fill)


def gradient(n: int) -> Image.Image:
    """135-degree navy -> teal gradient with a soft top-left highlight."""
    ys, xs = np.mgrid[0:n, 0:n].astype(np.float32) / (n - 1)
    t = np.clip((xs * 0.55 + ys * 0.45), 0, 1)[..., None]
    c0 = np.array(NAVY, np.float32)
    c1 = np.array(TEAL, np.float32)
    rgb = c0 * (1 - t) + c1 * t

    # Soft light from the top-left corner for a little depth.
    dist = np.sqrt((xs - 0.15) ** 2 + (ys - 0.05) ** 2)[..., None]
    glow = np.clip(1 - dist / 0.85, 0, 1) ** 2 * 0.10
    rgb = rgb * (1 - glow) + 255 * glow

    arr = np.concatenate([rgb, np.full((n, n, 1), 255, np.float32)], axis=2)
    return Image.fromarray(arr.astype(np.uint8), "RGBA")


def mark_layer(n: int, mark_size: float, color=WHITE, shadow: bool = True):
    """Transparent n x n layer with the mark centred (plus a soft shadow)."""
    layer = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    if shadow:
        sh = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        draw_mark(sh, n / 2, n / 2 + n * 0.012, mark_size, (8, 20, 60, 90))
        sh = sh.filter(ImageFilter.GaussianBlur(n * 0.018))
        layer = Image.alpha_composite(layer, sh)
    fg = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    draw_mark(fg, n / 2, n / 2, mark_size, color + (255,))
    return Image.alpha_composite(layer, fg)


def rounded_mask(n: int, radius_frac: float) -> Image.Image:
    m = Image.new("L", (n, n), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        [0, 0, n - 1, n - 1], radius=n * radius_frac, fill=255
    )
    return m


def tile(size: int, rounded: bool) -> Image.Image:
    n = size * SS
    img = Image.alpha_composite(gradient(n), mark_layer(n, n * MARK_IN_TILE))
    if rounded:
        img.putalpha(rounded_mask(n, TILE_RADIUS))
    return img.resize((size, size), Image.LANCZOS)


def save(img: Image.Image, name: str, opaque: bool = False) -> None:
    path = os.path.join(OUT_DIR, name)
    if opaque:
        img = img.convert("RGB")
    img.save(path, optimize=True)
    print(f"  wrote {os.path.relpath(path)}  {img.size[0]}x{img.size[1]}")


# ---------------------------------------------------------------------------
# SVG export (same geometry, for designers / future edits)
# ---------------------------------------------------------------------------
def svg() -> str:
    s = 1024
    m = s * MARK_IN_TILE
    c = s / 2

    def p(x, y):
        return f"{c + x * m:.1f},{c + y * m:.1f}"

    r = (0.5 - RING_WIDTH / 2) * m
    a0 = math.radians(RING_GAP_DEG)
    x0, y0 = c + r * math.cos(a0), c + r * math.sin(a0)
    x1, y1 = c + r * math.cos(-a0), c + r * math.sin(-a0)
    ends = [_ring_end(RING_GAP_DEG), _ring_end(-RING_GAP_DEG)]
    kw, kh = TASSEL_KNOB
    hex_ = lambda rgb: "#%02X%02X%02X" % rgb  # noqa: E731
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {s} {s}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{hex_(NAVY)}"/>
      <stop offset="1" stop-color="{hex_(TEAL)}"/>
    </linearGradient>
  </defs>
  <rect width="{s}" height="{s}" rx="{s * TILE_RADIUS:.0f}" fill="url(#bg)"/>
  <g fill="#FFFFFF">
    <path d="M{x0:.1f},{y0:.1f} A{r:.1f},{r:.1f} 0 1 1 {x1:.1f},{y1:.1f}"
          fill="none" stroke="#FFFFFF" stroke-width="{RING_WIDTH * m:.1f}"/>
    {''.join(f'<circle cx="{c + ex * m:.1f}" cy="{c + ey * m:.1f}" r="{NODE_RADIUS * m:.1f}"/>' for ex, ey in ends)}
    <polygon points="{' '.join(p(x, y) for x, y in DIAMOND)}"/>
    <polygon points="{' '.join(p(x, y) for x, y in BAND)}"/>
    <rect x="{c + (TASSEL_X - TASSEL_WIDTH / 2) * m:.1f}" y="{c + TASSEL_TOP * m:.1f}"
          width="{TASSEL_WIDTH * m:.1f}" height="{(TASSEL_BOTTOM - TASSEL_TOP) * m:.1f}"/>
    <rect x="{c + (TASSEL_X - kw / 2) * m:.1f}" y="{c + (TASSEL_BOTTOM - 0.01) * m:.1f}"
          width="{kw * m:.1f}" height="{kh * m:.1f}" rx="{kw * m / 2.2:.1f}"/>
  </g>
</svg>
"""


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Generating CampusHub brand assets...")

    with open(os.path.join(OUT_DIR, "logo.svg"), "w", encoding="utf-8") as f:
        f.write(svg())
    print("  wrote assets/branding/logo.svg")

    save(tile(768, rounded=True), "logo.png")
    save(tile(1024, rounded=False), "icon_ios.png", opaque=True)
    save(tile(1024, rounded=True), "icon_android_legacy.png")

    # Adaptive icon: 108dp canvas, content must stay inside the 66dp safe zone.
    n = 1024
    big = n * SS
    fg = mark_layer(big, big * 0.5).resize((n, n), Image.LANCZOS)
    save(fg, "icon_foreground.png")
    save(gradient(n), "icon_background.png", opaque=True)
    mono = mark_layer(big, big * 0.5, shadow=False).resize((n, n), Image.LANCZOS)
    save(mono, "icon_monochrome.png")

    # Native splash: 448px @4x == 112dp, the same size the Flutter splash
    # page starts at, so the hand-off between the two is seamless.
    save(tile(448, rounded=True), "splash_logo.png")

    # Android 12+: 1152px canvas, icon must fit a 768px circle.
    a12 = Image.new("RGBA", (1152, 1152), (0, 0, 0, 0))
    t = tile(520, rounded=True)
    a12.paste(t, ((1152 - 520) // 2, (1152 - 520) // 2), t)
    save(a12, "splash_android12.png")


if __name__ == "__main__":
    main()
