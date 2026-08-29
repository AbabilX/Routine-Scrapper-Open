# Architecture

DIU keeps UI, query logic, and data files separate so Teacher/Room views and PDF upload can plug in later without rewriting Student.

The running app is **Flutter**. Kotlin + Compose remains under `app/` as a behavior reference.

```
SAF / document picker  (Kotlin PdfPicker · iOS PdfPicker.swift)
                    ↓
User PDF  →  PdfWordExtractor + RoutinePdfParser  →  device routine.json (origin: user)
                                                    + user_routine.pdf
                                         ↓
                              AssetRoutineRepository (empty until first upload)
                                         ↓
                                   RoutineQueries
                                         ↓
                                 StudentViewModel
                                    ↙          ↘
                          StudentScreen    ClassReminderScheduler
                          (bell + PDF)     (OS local notification)
                                    ↓
                          student_cache.json  (query + reminders + profile + seenOnboarding)
                                            ↑
                                      AppShell (first-launch tour)
```

- `lib/domain` has no Flutter UI types.
- `lib/data` parses an uploaded DIU CSE routine PDF (same rules as `scripts/parse_routine_pdf.py`), stores JSON + PDF, and builds the section schedule export.
- PDF pick is native: Android Kotlin SAF (`PdfPicker` + MethodChannel `com.ababilx.diu/pdf_picker`). No `file_picker` plugin.
- `lib/ui/onboarding` is once-per-install; `seenOnboarding` lives in `student_cache.json` and SharedPreferences. Clears only when app storage is reset.
- `lib/ui/student/components` are one-job widgets.
- Theme is light and cute (`lib/ui/theme/app_colors.dart`); screens must not hardcode colors.
- Header faces: 12 kinds in `CuteFaceKind` — girl / boy animal pools; unspecified cycles bald-male faces.
- UX helpers live in `RoutineQueries` (now/next status, suggest chips); UI only renders them.
- Reminder fire-time lives in `ReminderRules` (`start − minutesBefore`). Scheduler only talks to the OS.

Routine JSON `meta.schemaVersion` is `1`. Slot fields stay the same so older files still parse.

Local files (app documents):

| File | Role |
|---|---|
| `routine.json` | Parsed user routine (`origin: user`). Missing/bundled file = no routine shown. |
| `user_routine.pdf` | Last uploaded source PDF. Replaced on the next upload. |
| `student_cache.json` | Last search, reminders, `seenOnboarding`, `displayName`, `gender`. |

Re-upload replaces both files. `RoutineQueries` stays unchanged.
