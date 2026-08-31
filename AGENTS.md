# Agent notes

## Architecture

UI (`lib/ui`) renders. Domain (`lib/domain`) has no Flutter UI types. Data (`lib/data`) loads and caches. Do not put search rules in widgets.

Do not put private URLs, endpoint paths, or credentials in markdown. Host and paths come from `--dart-define-from-file=.env` (`ApiConfig`, `ApiEndpoints`).

Full map: [PROJECT.md](PROJECT.md).
