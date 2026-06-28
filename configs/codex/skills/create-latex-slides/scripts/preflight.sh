#!/usr/bin/env bash
# Pre-build lint for a slide.tex. Catches errors that pdflatex reports with
# cryptic messages. Run BEFORE build.sh to save a compile cycle.
#
#   ./preflight.sh [project-dir]

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
cd "$PROJECT_DIR"

errors=0

if [[ ! -f slide.tex ]]; then
    echo "error: slide.tex not found" >&2
    exit 1
fi

# A frame that contains lstlisting/verbatim/minted needs [fragile].
# We grep for frame-blocks containing such environments and check for [fragile].
python3 - <<'PY'
import re, sys, pathlib
text = pathlib.Path("slide.tex").read_text()
# Find each \begin{frame}...\end{frame} block
blocks = re.findall(r"\\begin\{frame\}[^\n]*\n.*?\\end\{frame\}", text, flags=re.DOTALL)
bad = []
for block in blocks:
    first_line = block.split("\n", 1)[0]
    has_verbatim = bool(re.search(r"\\begin\{(lstlisting|verbatim|minted)\}", block))
    has_fragile = "[fragile]" in first_line
    if has_verbatim and not has_fragile:
        title = re.search(r"\\begin\{frame\}(?:\[[^\]]*\])?\{([^}]+)\}", first_line)
        bad.append(title.group(1) if title else first_line[:60])
if bad:
    print("error: frames with lstlisting/verbatim/minted must use [fragile]:", file=sys.stderr)
    for t in bad:
        print(f"  - {t}", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then errors=$((errors+1)); fi

# Detect \includesvg — we don't ship the svg package; pre-convert to PDF instead.
if grep -nE '^[^%]*\\includesvg' slide.tex >/dev/null 2>&1; then
    echo "error: \\includesvg detected — pre-convert SVGs to PDF with rsvg-convert and use \\includegraphics" >&2
    grep -nE '^[^%]*\\includesvg' slide.tex >&2 || true
    errors=$((errors+1))
fi

# Detect auto-pst-pdf — requires shell-escape; remove it unless truly needed.
if grep -nE '^[^%]*\\usepackage\{auto-pst-pdf\}' slide.tex >/dev/null 2>&1; then
    echo "error: auto-pst-pdf requires --shell-escape; remove the \\usepackage line unless you need pstricks" >&2
    errors=$((errors+1))
fi

# Detect referenced fig/ files that don't exist.
python3 - <<'PY'
import re, pathlib, sys
tex = pathlib.Path("slide.tex").read_text()
missing = []
for m in re.finditer(r"\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}", tex):
    path = m.group(1)
    if not path.endswith((".pdf", ".png", ".jpg", ".jpeg")):
        # allow omitted extension; pdflatex will auto-resolve
        candidates = [f"{path}.pdf", f"{path}.png", f"{path}.jpg", f"{path}.jpeg"]
        if not any(pathlib.Path(c).exists() for c in candidates):
            missing.append(path)
    elif not pathlib.Path(path).exists():
        missing.append(path)
if missing:
    print("error: \\includegraphics references missing files:", file=sys.stderr)
    for p in missing:
        print(f"  - {p}", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then errors=$((errors+1)); fi

if [[ $errors -gt 0 ]]; then
    exit 1
fi
echo "preflight: ok"
