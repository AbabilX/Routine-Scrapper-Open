# Architecture

rDIU keeps UI, query logic, and data files separate so Teacher/Room views and PDF upload can plug in later without rewriting Student.

The running app is **Flutter**. Kotlin + Compose remains under `app/` as a behavior reference.

```
PDF  →  scripts/parse_routine_pdf.py  →  assets JSON
                                         ↓
                              AssetRoutineRepository
                                         ↓
                                   RoutineQueries
                                         ↓
                                 StudentViewModel
                                         ↓
                                   StudentScreen
```

- `lib/domain` has no Flutter UI types.
- `lib/data` only loads JSON / shares the bundled PDF / remembers last student query (`StudentPrefs`).
- `lib/ui/student/components` are one-job widgets.
- Theme is light and cute (`lib/ui/theme/app_colors.dart`); screens must not hardcode colors.
- UX helpers live in `RoutineQueries` (now/next status, suggest chips); UI only renders them.

Future PDF upload should implement the same repository shape and keep `RoutineQueries` unchanged.
