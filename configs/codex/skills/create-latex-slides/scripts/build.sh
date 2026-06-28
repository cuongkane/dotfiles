#!/usr/bin/env bash
# One-shot build for a slide project produced by create-latex-slides.
#
#   ./build.sh                  # auto-detect slide.tex in cwd
#   ./build.sh path/to/project  # build the project at that path
#
# Steps performed:
#   1. Convert every fig/*.svg to fig/*.pdf via rsvg-convert (skip if up-to-date)
#   2. Run pdflatex twice (ToC needs a second pass)
#   3. Open the resulting PDF on macOS
#
# Requires: pdflatex (TeX Live) and rsvg-convert (brew install librsvg).
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
cd "$PROJECT_DIR"

if [[ ! -f slide.tex ]]; then
    echo "error: slide.tex not found in $PROJECT_DIR" >&2
    exit 1
fi

# 1. SVG → PDF (only if PDF is missing or older)
if [[ -d fig ]]; then
    shopt -s nullglob
    for svg in fig/*.svg; do
        pdf="${svg%.svg}.pdf"
        if [[ ! -f "$pdf" || "$svg" -nt "$pdf" ]]; then
            if command -v rsvg-convert >/dev/null 2>&1; then
                rsvg-convert -f pdf -o "$pdf" "$svg"
                echo "converted: $svg"
            else
                echo "warning: rsvg-convert not found; skipping $svg" >&2
            fi
        fi
    done
    shopt -u nullglob
fi

# 2. Two pdflatex passes (required for ToC / cross-references)
pdflatex -interaction=nonstopmode slide.tex >/dev/null
pdflatex -interaction=nonstopmode slide.tex >/dev/null

# 3. Report result
if [[ -f slide.pdf ]]; then
    pages=$(pdfinfo slide.pdf 2>/dev/null | awk '/^Pages:/ {print $2}' || echo "?")
    echo "built: slide.pdf (${pages} pages)"
    if [[ "$(uname)" == "Darwin" && -z "${NO_OPEN:-}" ]]; then
        open slide.pdf
    fi
else
    echo "error: slide.pdf was not produced; check slide.log" >&2
    exit 1
fi
