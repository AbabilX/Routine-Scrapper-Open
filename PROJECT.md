# Architecture

DIU keeps UI, query logic, and data files separate so Teacher/Room views and PDF upload can plug in later without rewriting Student.

The running app is **Flutter**. Kotlin + Compose remains under `app/` as a behavior reference.

```
PDF  →  scripts/parse_routine_pdf.py  →  assets JSON (schemaVersion)
                                         ↓ first launch / newer bundled
                              device routine.json   (LocalRoutineStore)
                                         ↓
                              AssetRoutineRepository
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
- `lib/data` loads JSON, copies it onto the device, builds the section schedule PDF, and stores student cache / schedules reminders.
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
| `routine.json` | Device copy of the bundled routine. Replaced when bundled fingerprint changes. `origin: user` (future upload) is never overwritten. |
| `student_cache.json` | Last search, reminders, `seenOnboarding`, `displayName`, `gender`. |

Future PDF upload should write `routine.json` with `meta.origin = "user"` and keep `RoutineQueries` unchanged.
