# Architecture

DIU keeps UI, query logic, and data files separate so Teacher/Room views plug in without rewriting Student.

The running app is **Flutter**. Live routine data comes from the remote API. The host is **not** in git — see `.env.example` and `ApiConfig`.

```
.env  API_BASE_URL  →  --dart-define-from-file=.env  →  ApiConfig
                                              ↓
                                    RoutineApiClient (HTTP)
                                              ↓
                               LiveRoutineRepository  (map + version cache)
                                    ↙        ↓         ↘
                    StudentViewModel  TeacherViewModel  RoomViewModel
                         ↓                  ↓               ↓
                   StudentScreen      TeacherScreen    Room / Empty
                         ↓
              ClassReminderScheduler + PdfExporter (from fetched slots)
                         ↓
              student_cache.json  (query + reminders + profile)
              api_cache/          (version + last schedules)
```

- `lib/domain` has no Flutter UI types.
- `lib/data/api` talks to the network and disk cache. UI never builds URLs.
- `RoutineQueries` still builds timelines / now-next from `ClassSlot`.
- PDF **upload** is removed. Section PDF **export** still builds from the fetched week.
- Department is CSE only for this slice.
- Student search: autocomplete → select batch → `POST /api/schedule`.
- Teacher / Room / Empty keep their screens; data is live.
- `/api/routine_version` invalidates `api_cache/` when the remote version changes.
- Theme is light and cute (`lib/ui/theme/app_colors.dart`); screens must not hardcode colors.

## API environment (open source)

The live API host is **not** in git. Agents and humans must not hardcode it.

| File | Role |
|---|---|
| `.env` | Local `API_BASE_URL`. Gitignored. |
| `.env.example` | Empty `API_BASE_URL=` for contributors. |
| `lib/data/api/api_config.dart` | Reads `API_BASE_URL` via `--dart-define-from-file=.env`. |

```bash
cp .env.example .env   # then set API_BASE_URL locally
flutter run --dart-define-from-file=.env
```

Use `ApiConfig.uri('/api/…')` from data layer only. Never log the base URL. Cursor rule: `.cursor/rules/api-env.mdc`.

Local files (app documents):

| File | Role |
|---|---|
| `api_cache/` | Version + last successful schedule / room lists. |
| `student_cache.json` | Last search, reminders, `seenOnboarding`, `displayName`, `gender`. |
