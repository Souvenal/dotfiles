---
description: prefer agent-browser skill over WebFetch for web content fetching
---

# Use `agent-browser` as the Default Web Content Fetcher

---

When fetching/searching web content, priority:

1. **`agent-browser`** (via `Skill` tool): Use for browsing, searching, scraping, form-filling. If unavailable, tell user to install it.
2. **`WebFetch`** (special case only): Use **only when certain** target is purely static API ref or docs page (e.g., `developer.mozilla.org`, `pkg.go.dev`, `docs.rs`, stdlib docs). When in doubt, use agent-browser.
3. **Fallback — agent-browser on WebFetch failure**: Many sites block `claude.ai` IP range. If `WebFetch` fails/errors, immediately retry with `agent-browser`. Do not report failure without trying agent-browser first.