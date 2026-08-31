# CLAUDE.md

## Architecture

- UI (`lib/ui`) renders. Domain (`lib/domain`) has no Flutter UI types.
- Data (`lib/data`) loads and caches routine. Widgets do not contain search rules.
- Theme tokens live in `lib/ui/theme/`. Do not hardcode colors.
- Do not put private URLs, endpoint paths, or credentials in markdown or committed source. Host and paths come from `--dart-define-from-file=.env` (`ApiConfig`, `ApiEndpoints`).

Full map: [PROJECT.md](PROJECT.md).
