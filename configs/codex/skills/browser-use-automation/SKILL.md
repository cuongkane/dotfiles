---
name: browser-use-automation
description: Control and inspect a browser with the browser-use CLI. Use when the user asks to use browser-use, open a page interactively, inspect browser state, click/type/scroll through a UI, capture screenshots, manage browser-use sessions, or run browser-use as an MCP/browser automation helper.
---

# Browser Use Automation

Use `browser-use` for interactive browser control and page-state inspection. Prefer raw Playwright for deterministic viewport regression checks, console-log collection, and scripted screenshot matrices.

## Core commands

Check installation:

```bash
browser-use doctor
browser-use install
```

Open and inspect a page:

```bash
browser-use open http://localhost:3000
browser-use state
browser-use screenshot /tmp/browser-use.png
browser-use screenshot --full /tmp/browser-use-full.png
```

Interact with indexed elements from `browser-use state`:

```bash
browser-use click 12
browser-use type "text to type"
browser-use input 8 "replacement text"
browser-use scroll down
browser-use keys Tab
browser-use wait 2
```

Manage sessions:

```bash
browser-use sessions
browser-use close
browser-use --session checkout open http://localhost:3000
```

## Workflow

1. Start the target app if it is local.
2. Run `browser-use open <url>`.
3. Run `browser-use state` to get URL, title, and interactable element indexes.
4. Use index-based commands such as `click`, `input`, `type`, `scroll`, and `keys`.
5. Capture screenshots to `/tmp` and inspect them with `view_image` when available.
6. Close the session when finished with `browser-use close`.

## Notes

- `browser-use` creates config/profile state under the user's home directory, so sandboxed runs may need escalated permissions.
- It rejects some non-HTTP URLs such as `data:` URLs. Use `http://localhost:<port>` or normal `https://` URLs for verification.
- Browser-use cloud features require an API key; local browser control does not.
- Use `browser-use --headed ...` when the user wants to see the browser window.
