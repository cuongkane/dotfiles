---
name: browser-ui-debugger
description: Inspect and debug web UI rendering with Playwright. Use when the user asks Codex to open a local or remote web page, check browser rendering, find visual layout issues, verify responsive behavior, inspect screenshots, or adjust frontend UI based on what appears in a real browser.
---

# Browser UI Debugger

Use Playwright to inspect real browser rendering before making UI claims. Prefer Chromium unless the user asks for another browser.

Use `browser-use` when the task benefits from a higher-level browser agent or interactive browser state commands. Use raw Playwright when the task needs deterministic screenshots, console logs, viewport checks, or repeatable UI regression verification.

## Workflow

1. Start the app's dev server if needed and keep the server session running.
2. Use Playwright to open the target URL at desktop and mobile viewports.
3. Capture screenshots to `/tmp` or the repo's temporary output directory.
4. Inspect screenshots with `view_image` when available.
5. Check for obvious rendering issues:
   - Text overlap, clipping, unreadable contrast, or overflow.
   - Broken image/font/icon loading.
   - Layout jumps between viewport sizes.
   - Controls that are too small, hidden, disabled unexpectedly, or misaligned.
   - Empty canvases, blank app roots, hydration errors, or console errors.
6. Make focused UI fixes in the relevant code.
7. Re-run Playwright screenshots after edits and compare the result.

## Quick commands

Check the installed CLI:

```bash
playwright --version
playwright install chromium
```

Take a screenshot of a local app:

```bash
playwright screenshot --browser chromium http://localhost:3000 /tmp/ui-desktop.png
playwright screenshot --browser chromium --viewport-size=390,844 http://localhost:3000 /tmp/ui-mobile.png
```

Use browser-use for interactive browser control:

```bash
browser-use open http://localhost:3000
browser-use state
browser-use screenshot /tmp/browser-use.png
browser-use click 12
browser-use type "user@example.com"
browser-use input 8 "user@example.com"
```

Record a trace when screenshots are not enough:

```bash
playwright open --browser chromium http://localhost:3000
```

## Script pattern

For repeatable checks, create a temporary script instead of relying on one-off commands:

```javascript
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
  page.on('console', msg => console.log(`[console:${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => console.log(`[pageerror] ${err.message}`));
  await page.goto(process.argv[2], { waitUntil: 'networkidle' });
  await page.screenshot({ path: process.argv[3], fullPage: true });
  await browser.close();
})();
```

Run it with:

```bash
node /tmp/check-ui.js http://localhost:3000 /tmp/ui.png
```

## Notes

- If the app requires authentication, ask the user for the safest way to access a test account or use an already-authenticated local profile only with explicit permission.
- Do not install browser dependencies or packages without user approval when that changes system state.
- For animation or canvas-heavy pages, verify that the screenshot is nonblank and that visible pixels change after interaction or time passes.
