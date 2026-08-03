# xp

Experimental Rails playground: different concepts, problems, and solutions—features, utilities, integrations, and tools I want to try, build, or test.

This is not a single product roadmap. Each area can grow independently. When something is useful, it stays in the app with tests; when it is scratch work, it may live under `playground/`.

## Table of contents

| Experiment | Summary | Write-up |
|------------|---------|----------|
| URL shortener | Snowflake ids, Base62 slugs, redirect API | [`write-ups/url-shortener.md`](write-ups/url-shortener.md) |

_Add a row when you add another experiment and add `write-ups/<slug>.md` (see [`write-ups/README.md`](write-ups/README.md))._

## Documentation: write-ups vs notes

Two places on purpose—they answer different questions.

| | **`write-ups/`** | **`app/services/.../notes/`** |
|--|------------------|----------------------------------|
| **Scope** | Whole experiment (many files) | One service or topic |
| **Good for** | Case studies, architecture, flow, “how this feature hangs together” | Algorithms, gotchas, research, bugs during implementation |
| **Example** | [`write-ups/url-shortener.md`](write-ups/url-shortener.md) | [`app/services/utils/notes/base62.md`](app/services/utils/notes/base62.md) |

**`write-ups/`** (project root)

- Index: [`write-ups/README.md`](write-ups/README.md)
- One file per experiment: `write-ups/<slug>.md` (e.g. `url-shortener.md`)
- Link out to code paths and to service-level notes—don’t duplicate Base62 math here; link to `utils/notes/base62.md`

**`notes/`** next to code (unchanged)

| Kind of code | Notes location | Index |
|--------------|----------------|--------|
| Shared utilities | `app/services/utils/notes/` | [`utils/notes/README.md`](app/services/utils/notes/README.md) |
| Domain services | `app/services/<name>/notes/` | `notes/README.md` in that folder |
| Playground | `app/services/playground/<topic>/notes/` | e.g. [`concurrency/notes/`](app/services/playground/concurrency/notes/) |

Use **`.md` only** in both places (not `.rb` under `app/`), so Zeitwerk does not load docs as code.

The root README stays at **project overview + TOC + setup**. Each experiment’s details live in **`write-ups/<slug>.md`** only—no duplicate sections here.

---

## App setup

Standard Rails 8 API app (PostgreSQL). From the project root:

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Run the full suite:

```bash
bundle exec rspec
```
