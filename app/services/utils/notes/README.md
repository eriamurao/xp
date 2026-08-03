# Utils notes

The Ruby services in the parent `utils/` folder are **general-purpose utilities**. They are not tied to a single feature and can be used **anywhere** in the application.

This directory holds **development notes**, not API documentation. Each utility has its own markdown file where you can capture what you learned during research and implementation: design choices, bugs, edge cases, gotchas, and open questions.

## Table of contents

| Utility | Service | Notes |
|--------|---------|--------|
| Base62 | [`base62_service.rb`](../base62_service.rb) | [base62.md](base62.md) |

When you add a new utility, add a row here and create a matching note file (for example `base64.md`).
