#!/usr/bin/env python3
"""
Convert dark-themed SVGs to a light theme suitable for white-background slides.

Usage:
    python3 lighten_svg.py <dir-or-file.svg> [more-files...]

Edits files in place. Run this BEFORE converting SVG -> PDF with rsvg-convert.

Color mapping reflects the common dark-theme palette used in many design-blog
SVGs (navy backgrounds, neon accents, light gray body text). Adjust as needed.
"""
import re
import sys
import glob
import os

# Dark theme -> Light theme
COLOR_MAP = {
    # Dark backgrounds -> light / transparent
    '#1a1a2e': '#f8f9fa',
    '#16213e': '#f0f2f5',
    '#0f3460': '#e8edf2',
    '#1a1a4e': '#e8edf2',
    '#1e1e3a': '#f5f5f5',
    '#2a2a4a': '#f0f0f0',
    '#1a3a5c': '#e6f0f8',
    '#12122a': '#f8f9fa',
    '#2d1a3e': '#fdf0f2',
    '#1a3a2c': '#eef8ee',
    '#0a0a1e': '#2d2d2d',  # terminal header stays dark-ish

    # Dark strokes -> medium gray
    '#334': '#cccccc',
    '#556': '#888888',

    # Light text -> dark text
    '#8899aa': '#444444',
    '#7a8a9a': '#555555',
    '#aab':     '#555555',
    '#667':     '#666666',
    '#ffccd5': '#992233',

    # Accent colors -> darker for readability on white
    '#53d8fb': '#0077bb',
    '#f0a500': '#cc7700',
    '#7ed957': '#228833',
    '#e94560': '#cc2244',
    '#c23152': '#aa1133',
}


def replace_colors(content: str) -> str:
    for old, new in COLOR_MAP.items():
        content = content.replace(f'stop-color:{old}', f'stop-color:{new}')
        content = content.replace(f'fill="{old}"',     f'fill="{new}"')
        content = content.replace(f"fill='{old}'",     f"fill='{new}'")
        content = content.replace(f'stroke="{old}"',   f'stroke="{new}"')
        content = content.replace(f"stroke='{old}'",   f"stroke='{new}'")
        content = content.replace(f'fill:{old}',       f'fill:{new}')
        content = content.replace(f'stroke:{old}',     f'stroke:{new}')

    # fill="white" on text/tspan -> dark
    content = re.sub(r'(<text[^>]*?)fill="white"',  r'\1fill="#222222"', content)
    content = re.sub(r'(<tspan[^>]*?)fill="white"', r'\1fill="#222222"', content)

    # First full-size background rect with a gradient fill -> none (transparent)
    content = re.sub(
        r'(<rect[^/]*?width="(?:100%|\d{3,})"[^/]*?height="(?:100%|\d{3,})"[^/]*?)fill="url\(#[^"]*\)"',
        r'\1fill="none"',
        content,
        count=1,
    )
    content = re.sub(
        r'(<rect\s+width="(?:100%|\d{3,})"[^/]*?height="(?:100%|\d{3,})"[^/]*?)fill="url\(#[^"]*\)"',
        r'\1fill="none"',
        content,
        count=1,
    )

    # Lighten shadow opacities
    content = content.replace('flood-opacity="0.3"',  'flood-opacity="0.1"')
    content = content.replace('flood-opacity="0.5"',  'flood-opacity="0.15"')

    return content


DARK_SIGNATURES = ('#1a1a2e', '#16213e', '#0f3460', '#12122a')


def looks_dark(content: str) -> bool:
    """Heuristic: True if any signature dark-theme color appears in the SVG."""
    return any(sig in content for sig in DARK_SIGNATURES)


def process(path: str) -> bool:
    """Returns True if the file was modified, False if it was already light."""
    with open(path) as f:
        content = f.read()
    if not looks_dark(content):
        print(f'skipped (already light): {path}')
        return False
    new_content = replace_colors(content)
    with open(path, 'w') as f:
        f.write(new_content)
    print(f'lightened: {path}')
    return True


def main(argv: list[str]) -> None:
    if not argv:
        print(__doc__)
        sys.exit(1)

    files = []
    for arg in argv:
        if os.path.isdir(arg):
            files.extend(sorted(glob.glob(os.path.join(arg, '*.svg'))))
        elif arg.endswith('.svg') and os.path.isfile(arg):
            files.append(arg)
        else:
            print(f'skip (not .svg or dir): {arg}', file=sys.stderr)

    if not files:
        print('no SVG files found', file=sys.stderr)
        sys.exit(1)

    for f in files:
        process(f)


if __name__ == '__main__':
    main(sys.argv[1:])
