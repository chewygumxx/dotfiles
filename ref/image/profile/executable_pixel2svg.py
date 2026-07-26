#!/usr/bin/env python3
# pixel2svg.py
# Requires: Pillow (`pip install Pillow`)
from PIL import Image
import argparse

def color_hex(r,g,b):
    return f'#{r:02x}{g:02x}{b:02x}'

def main():
    p = argparse.ArgumentParser(description="Convert pixel art PNG -> SVG (rect per pixel).")
    p.add_argument("input", help="input PNG (any size)")
    p.add_argument("output", help="output SVG filename")
    p.add_argument("--scale", type=int, default=8, help="output width/height multiplier (for the SVG width/height attrs)")
    p.add_argument("--no-merge", dest="merge", action="store_false", help="do NOT merge horizontal runs (one rect per pixel)")
    p.add_argument("--background", default=None, help="optional background color, e.g. #ffffff")
    args = p.parse_args()

    img = Image.open(args.input).convert("RGBA")
    w, h = img.size
    px = img.load()

    svg_w = w * args.scale
    svg_h = h * args.scale

    with open(args.output, "w", encoding="utf-8") as out:
        out.write('<?xml version="1.0" encoding="utf-8"?>\n')
        out.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{svg_w}" height="{svg_h}" viewBox="0 0 {w} {h}" shape-rendering="crispEdges" version="1.1">\n')

        if args.background:
            out.write(f'  <rect x="0" y="0" width="{w}" height="{h}" fill="{args.background}" />\n')

        for y in range(h):
            x = 0
            while x < w:
                r,g,b,a = px[x,y]
                if a == 0:
                    x += 1
                    continue
                start = x
                if args.merge:
                    # merge horizontal run of identical rgba
                    while x + 1 < w and px[x+1, y] == (r,g,b,a):
                        x += 1
                    run = x - start + 1
                    x += 1
                else:
                    run = 1
                    x += 1

                color = color_hex(r,g,b)
                if a == 255:
                    out.write(f'  <rect x="{start}" y="{y}" width="{run}" height="1" fill="{color}" />\n')
                else:
                    opacity = a / 255.0
                    out.write(f'  <rect x="{start}" y="{y}" width="{run}" height="1" fill="{color}" fill-opacity="{opacity:.3f}" />\n')

        out.write('</svg>\n')

if __name__ == "__main__":
    main()

