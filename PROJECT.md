# Architecture

DIU keeps UI, query logic, and data separate so Teacher/Room views plug in without rewriting Student.

The running app is **Flutter**. Kotlin + Compose remains under `app/` as a behavior reference.

```
data/  (load + cache)
        ↓
    domain/RoutineQueries
        ↓
StudentViewModel / TeacherViewModel / RoomViewModel
        ↓
StudentScreen / TeacherScreen / Empty / About
        ↓
ClassReminderScheduler + PdfExporter
        ↓
student_cache.json  (query + reminders + profile)
```

- `lib/domain` has no Flutter UI types.
- `lib/data` loads and caches routine. UI does not build network details.
- `RoutineQueries` builds timelines / now-next from `ClassSlot`.
- Section PDF is built on-device from the current week (title + table). No PDF download from the API.
- Department is CSE only for this slice (Teacher also supports BBA).
- Student search: type → suggestions → select batch → show week.
- Bottom nav: Student · Teacher · Empty rooms · About (no Room-search tab).
- License is **GPL-3.0-or-later** (open source / copyleft). See `LICENSE`.
- `AboutScreen` is trust copy (open source, no data collection) + GitHub link `AbabilX/Routine-Scrapper-Open`.
- Theme is light and cute (`lib/ui/theme/app_colors.dart`); screens must not hardcode colors.
- Shared cute shell: `lib/ui/components/cute_page.dart` (+ header, blobs, empty hint).

Local files (app documents):

| File | Role |
|---|---|
| on-device cache | Last successful routine lists |
| `student_cache.json` | Last search, reminders, `seenOnboarding`, `displayName`, `gender` |
