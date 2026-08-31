# Agent notes

## API host

Live API base URL is **not** in this repo. Copy `.env.example` → `.env`, set `API_BASE_URL`, run with `--dart-define-from-file=.env`. Dart code must use `ApiConfig` only. See `.cursor/rules/api-env.mdc`.

## Architecture

UI (`lib/ui`) renders. Domain (`lib/domain`) has no Flutter UI types. Data (`lib/data`) loads, caches, and calls the API via `ApiConfig`. Do not put search rules in widgets.

Full map: [PROJECT.md](PROJECT.md).
