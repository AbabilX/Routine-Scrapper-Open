# CLAUDE.md

## API environment

- Real `API_BASE_URL` lives in gitignored `.env`.
- Committed placeholder: `.env.example`.
- App reads it at compile time: `lib/data/api/api_config.dart`.
- Never hardcode the live host in source or docs.
- Launch: `flutter run --dart-define-from-file=.env` (also `.vscode/launch.json`).

Rule file: `.cursor/rules/api-env.mdc`.
