---
name: create-latex-slides
description: Create Beamer (LaTeX) slide decks from a blog post, markdown article, technical document, or outline. Uses the UTU Beamer theme with a proven layout (columns, colored callout boxes, figure/table support). Trigger this skill whenever the user asks to build slides, a presentation, a deck, a talk, or a Beamer/LaTeX slideshow from content — including when they say "turn this blog into slides", "create a presentation for X", "make a Beamer deck", or provide an mdx/md/pdf and ask for a slide version. Handles SVG figures by converting them to PDF via rsvg-convert and can auto-lighten dark-themed diagrams for a white-background deck.
---

# Create LaTeX Beamer Slides

Build a presentation-ready Beamer deck using a proven template (UTU theme, 16:9). Works from any source (blog post, markdown, outline, technical doc) or from scratch.

## When to use

- User provides a blog post / article / design doc and asks for slides
- User wants a Beamer/LaTeX presentation on a topic
- User asks to "turn X into a slide deck" or "create slides for Y"

## Directory layout produced

```
<project-dir>/
├── slide.tex        # Main deck — edit content here
├── UTU.sty          # Beamer theme (do not edit unless asked)
├── fig/             # Images (PNG / converted-from-SVG PDF)
│   ├── *.pdf
│   └── *.svg        # Originals kept; rsvg-convert generates the .pdf
└── .gitignore
```

## Workflow

### 1. Understand the content

If the user provides a source file (blog post, mdx, markdown, pdf), read it first. Extract:
- Title + subtitle (usually from frontmatter)
- Natural sectioning (H1/H2 headings)
- Key figures referenced (`![...](...svg)` or `.png`)
- Code blocks, tables, callouts
- Main takeaways for a summary slide

If the user provides only a topic, ask one clarifying question about audience/depth if it's ambiguous, then proceed.

### 2. Set up the project directory

Copy the template files to the project directory:

```bash
cp ~/.claude/skills/create-latex-slides/templates/slide.tex <project-dir>/slide.tex
cp ~/.claude/skills/create-latex-slides/templates/UTU.sty  <project-dir>/UTU.sty
cp ~/.claude/skills/create-latex-slides/templates/.gitignore <project-dir>/.gitignore
mkdir -p <project-dir>/fig
```

### 3. Handle images

**SVG images** — copy the source SVGs into `fig/` and convert to PDF. The bundled `build.sh` does this automatically (see step 5), so you usually don't need to run rsvg-convert by hand.

If the source SVGs use a **dark theme** (navy/near-black backgrounds, neon accents — common in modern design blogs), they'll look wrong on the white slide background. Run the lightener first:

```bash
python3 ~/.claude/skills/create-latex-slides/scripts/lighten_svg.py <project-dir>/fig/
```

The script auto-detects the signature dark colors (`#1a1a2e`, `#16213e`, etc.) and flips the palette. It's a no-op if the SVGs are already light.

Reference the `.pdf` version in slides (not `.svg`): `\includegraphics[width=0.85\textwidth]{fig/pipeline_flow.pdf}`.

**PNG/JPG** — drop into `fig/` and include normally.

### 4. Fill in slide content

Edit `slide.tex`. Core patterns (see `references/layout-patterns.md` for copy-paste snippets):

- `\section{Name}` — appears in the ToC; the theme auto-inserts a ToC frame at each section boundary
- `\begin{frame}{Title}...\end{frame}` — one slide
- `\begin{frame}[fragile]{Title}` — required if the frame contains `lstlisting`, `verbatim`, or `minted`
- `\colorbox{utu_green!20}{...}` — takeaway callout; `utu_blue!20` (info), `utu_pink!20` (warning)
- `columns` environment — two-column layouts
- `\includegraphics[keepaspectratio, height=0.7\textheight]{fig/X.pdf}` — sized for a full-slide figure

#### How to map source content to slides

This is the biggest quality driver. Follow these heuristics:

- **Title frame** — always first. Use `\title[short]{long}` if the title is long; the short form prevents footer overflow.
- **Top-level structure** — every H1 in the source becomes a `\section{...}`. 3–7 sections total is the sweet spot. If the source has 15 H1s, group related ones under fewer sections.
- **Individual frames per H2** — each H2 subheading typically becomes one frame. If the content under an H2 is >8 bullets or spans two distinct ideas, split into two frames.
- **Diagrams get their own frame** — a figure referenced in the source should usually be a dedicated full-size frame, not squeezed into a bullet list. Let the image breathe.
- **Bullets are a compressed form, not a transcription.** The blog may have 4-line paragraphs; the slide gets them as 1-line bullets. Cut to the point.
- **Ratio of text to visuals**: aim for roughly 1 figure / callout / table every 3–4 text frames. Pure bullet decks are hard to watch for 30 minutes.
- **Closing** — always end with a `\section{Conclusion}` containing a summary frame (3–5 takeaways) and a `\Huge\calligra Thank You` frame.

#### Density guardrails

- **6–8 bullets max per frame.** If you need more, split the frame. Dense slides lose the audience — they read ahead and stop listening.
- **Avoid inline citations**: sources go in `\vfill {\tiny [1] ...}` at the bottom, not cluttering the bullet text.
- **Prefer `\textbf{}` for emphasis inside a frame.** Don't use sub-headings within a frame — if you need one, that's a signal to split the frame.

### 5. Build the PDF

Use the bundled build script (it handles SVG conversion, two pdflatex passes, and opens the result on macOS):

```bash
~/.claude/skills/create-latex-slides/scripts/build.sh <project-dir>
```

Or manually, from the project directory:

```bash
pdflatex -interaction=nonstopmode slide.tex
pdflatex -interaction=nonstopmode slide.tex   # second pass resolves ToC
```

Before building, optionally run the preflight lint to catch common issues:

```bash
~/.claude/skills/create-latex-slides/scripts/preflight.sh <project-dir>
```

It flags `lstlisting` without `[fragile]`, stray `\includesvg`, `auto-pst-pdf` usage, and missing figure files.

### 6. Common build errors

| Error | Fix |
|-------|-----|
| `Package auto-pst-pdf Error: shell escape not enabled` | Remove `\usepackage{auto-pst-pdf}` — not needed |
| `Paragraph ended before \lst@next was complete` | Frame contains `lstlisting`; add `[fragile]` option |
| `Package svg Error: Inkscape not detected` | Don't use `\includesvg`; pre-convert with rsvg-convert (build.sh does this) |
| Image not found | Path should be `fig/<name>.pdf` (not `.svg`); check file exists |
| Frame title overflows footer | Use `\title[short]{long form}` for the document title; keep frame titles under ~50 chars |

### 7. Preview

```bash
open <project-dir>/slide.pdf   # macOS; build.sh does this automatically
```

## Style conventions

- **16:9 aspect ratio** (default in template)
- **Visual-first**: prefer a figure + 3 bullets over a wall of text
- **Colored callouts**: `utu_green!20` (takeaway), `utu_blue!20` (info), `utu_pink!20` (warning)
- **Sections**: 3–7 total; each becomes a ToC frame automatically
- **Flow**: title frame → sections with content frames → conclusion section → Thank You

## Files in this skill

- `templates/slide.tex` — starter deck with placeholder sections; copy this first
- `templates/UTU.sty` — theme file (purple accent, smoothbars outer theme)
- `templates/.gitignore` — LaTeX build artifact ignores
- `references/layout-patterns.md` — copy-paste snippets for every common layout
- `scripts/build.sh` — one-shot build (SVG → PDF → pdflatex × 2 → open)
- `scripts/preflight.sh` — pre-build lint to catch errors early
- `scripts/lighten_svg.py` — convert dark-themed SVGs to light theme for white slides
