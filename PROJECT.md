# Architecture

rDIU keeps UI, query logic, and data files separate so Teacher/Room views and PDF upload can plug in later without rewriting Student.

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

- `domain` has no Android UI types.
- `data` only loads JSON / shares the bundled PDF / remembers last student query (`StudentPrefs`).
- `ui/student/components` are one-job composables.
- Theme is light and cute (`ui/theme/Color.kt`); screens must not hardcode colors.
- UX helpers live in `RoutineQueries` (now/next status, suggest chips); UI only renders them.

Future PDF upload should implement the same repository shape and keep `RoutineQueries` unchanged.
