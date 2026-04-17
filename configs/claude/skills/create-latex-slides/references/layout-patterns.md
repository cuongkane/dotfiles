# Layout Patterns — copy-paste snippets

Reference snippets for common slide layouts. All use the UTU theme (loaded by `\usepackage{UTU}`).

## Title frame

```latex
\begin{frame}
    {\small \titlepage}
\end{frame}
```

## Section divider (auto-generated)

The UTU theme inserts a ToC frame at each `\section{...}`. Just write:

```latex
\section{Section Name}
```

## Bullet list + callout

```latex
\begin{frame}{Frame Title}
    Lead-in sentence.

    \begin{itemize}
        \item \textbf{Point 1} -- detail
        \item \textbf{Point 2} -- detail
    \end{itemize}

    \colorbox{utu_green!20}{\parbox{0.9\textwidth}{
        \centering \textbf{Key takeaway}
    }}
\end{frame}
```

## Two-column

```latex
\begin{frame}{Frame Title}
    \begin{columns}[T]
        \begin{column}{0.48\textwidth}
            \textbf{Left}
            \begin{itemize}
                \item A
            \end{itemize}
        \end{column}
        \begin{column}{0.48\textwidth}
            \textbf{Right}
            \begin{itemize}
                \item B
            \end{itemize}
        \end{column}
    \end{columns}
\end{frame}
```

## Column with figure on the right

```latex
\begin{frame}{Frame Title}
    \begin{columns}[T]
        \begin{column}{0.55\textwidth}
            Text content here.
        \end{column}
        \begin{column}{0.42\textwidth}
            \begin{figure}
                \includegraphics[width=\textwidth]{fig/image.pdf}
                \caption{Caption}
            \end{figure}
        \end{column}
    \end{columns}
\end{frame}
```

## Full-size figure

```latex
\begin{frame}{Frame Title}
    \begin{figure}[htpb]
        \centering
        \includegraphics[keepaspectratio, height=0.8\textheight]{fig/image.pdf}
        \caption{Caption}
    \end{figure}
\end{frame}
```

## Code listing (needs `[fragile]`)

```latex
\begin{frame}[fragile]{Frame Title}
    \begin{lstlisting}[language=Python,basicstyle=\ttfamily\footnotesize]
def hello(name: str) -> str:
    return f"Hello, {name}!"
    \end{lstlisting}
\end{frame}
```

## Table

```latex
\begin{frame}{Comparison}
    \begin{center}
        \begin{tabular}{|l|c|c|}
            \hline
            \textbf{Metric} & \textbf{Option A} & \textbf{Option B} \\
            \hline
            Latency & 2ms & 5ms \\
            \hline
            Throughput & 10k/s & 4k/s \\
            \hline
        \end{tabular}
    \end{center}
\end{frame}
```

## Colored callout variants

```latex
% Green — takeaways, positive
\colorbox{utu_green!20}{\parbox{0.9\textwidth}{\centering \textbf{Key point}}}

% Blue — info, neutral
\colorbox{utu_blue!20}{\parbox{0.9\textwidth}{\centering \textbf{Info note}}}

% Pink — caution, problem
\colorbox{utu_pink!20}{\parbox{0.9\textwidth}{\centering \textbf{Warning}}}
```

## Equation

```latex
\begin{frame}{Formula}
    \begin{equation*}
        \sigma(v) = \mathcal{L}\Big(\text{code}(v),\ \{\sigma(u) : u \in \text{Deps}(v)\}\Big)
    \end{equation*}
    {\small where $\mathcal{L}$ = LLM, $\text{Deps}(v)$ = callees of $v$}
\end{frame}
```

## Final "Thank You"

```latex
\begin{frame}
    \begin{center}
        {\Huge\calligra Thank You}
    \end{center}
\end{frame}
```

## Quoted testimonial / callout

```latex
\colorbox{utu_blue!20}{\parbox{0.95\textwidth}{
    \textit{"Quote from a user here."} \\
    \vspace{0.1cm}
    --- Attribution, Role
}}
```

## Citation / footnote source

```latex
\begin{frame}{Frame with Source}
    \begin{itemize}
        \item \textbf{70\%} of developer time spent reading code$^{[1]}$
    \end{itemize}
    \vfill
    {\tiny
    [1] R.C. Martin, Clean Code (2008)
    }
\end{frame}
```

## Design guardrails

- **One idea per slide** — if a frame has >8 bullets, split it
- **Don't use `\includesvg`** — pre-convert SVGs to PDF with `rsvg-convert`
- **`[fragile]` is required** for any frame containing `lstlisting`, `verbatim`, or `minted`
- **Size images with `height=X\textheight`** (not `width`) for full-page figures to avoid overflow
- **No footer clutter** — cite with `\tiny` in `\vfill` at the bottom, not inline
