# Write-ups

Cross-cutting **case studies** for experiments that span many files—controller, models, routes, services, specs—not a single class.

Use this folder when you want one narrative for a **feature or module** (how it fits together, tradeoffs, end-to-end flow). Use [`app/services/.../notes/`](../app/services/utils/notes/README.md) for deep dives on **one** utility or service (Base62, Snowflake bits, mutex experiments, etc.).

| Document | What it covers |
|----------|----------------|
| [url-shortener.md](url-shortener.md) | Short link API, persistence, id + slug pipeline |

When you start a new multi-file experiment, add a row here and create `<slug>.md` (kebab-case, matching the name in the root README table of contents).
