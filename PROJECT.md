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
- `data` only loads JSON / shares the bundled PDF.
- `ui/student/components` are one-job composables.

Future PDF upload should implement the same repository shape and keep `RoutineQueries` unchanged.
