# DIU Routine Scrapper

DIU স্টুডেন্টদের জন্য **অফলাইন ক্লাস রুটিন** অ্যাপ। PDF ঘেঁটে ব্যাচ খুঁজে বের করার বদলে ব্যাচ কোড লিখলেই দিনভিত্তিক রুটিন দেখা যায়।

এখন শুধু **Student** ভিউ আছে। Teacher / Room / Empty পরে যোগ হবে — আর্কিটেকচার সেভাবেই রাখা।

| | |
|---|---|
| প্ল্যাটফর্ম | Flutter (Android + iOS) |
| প্যাকেজ | `com.ababilx.routinescrapper` |
| অ্যাপ নাম | DIU |
| ভার্সন | 0.1.0 |
| ডেটা | CSE Routine **V5 · Summer 2026** (অ্যাপে বান্ডল) |
| লাইসেন্স | [MIT](LICENSE) |

Kotlin + Compose অরিজিনাল `app/`-এ আছে (রেফারেন্স)। রান করার ডিফল্ট এখন Flutter।

---

## কেন এই প্রজেক্ট শেখার ভালো

ছোট অ্যাপ, কিন্তু আসল অ্যাপের মতো লেয়ার আছে। এখানে পড়লে বোঝা যায়:

1. **UI আলাদা, বিজনেস লজিক আলাদা** — স্ক্রিন বদলালে সার্চ ভাঙে না
2. **ডেটা সোর্স আলাদা** — আজ JSON, কাল PDF আপলোড; কোয়েরি একই থাকে
3. **Flutter widgets** — ছোট ছোট কম্পোনেন্ট জোড়া লাগিয়ে একটা স্ক্রিন
4. **PDF scraper** — ইউনিভার্সিটি রুটিন PDF কীভাবে স্ট্রাকচার্ড JSON হয়

পড়ার অর্ডার (প্রথম দিন):

1. এই README
2. `lib/main.dart` → `lib/ui/student/student_screen.dart`
3. `student_view_model.dart` → `lib/domain/routine_queries.dart`
4. `lib/data/asset_routine_repository.dart`

---

## কী কী করা যায়

- সার্চ: `68_C`, `71_B`, `68C`, বা শুধু `68` (সব সেকশন)
- `68_C` লিখলে `68_C1` / `68_C2` ল্যাব সাবসেকশনও মিলে
- শনি–বৃহস্পতি ডেট স্ট্রিপ
- পাশাপাশি ল্যাব স্লট এক কার্ডে, মাঝের ফাঁক **Break**
- Enrolled Courses সারাংশ + ডাউনলোড: সার্চ করা সেকশনের সাপ্তাহিক PDF (যে দিনে ক্লাস আছে)
- ক্লাস কার্ডে বেল — ৫ / ১০ / ১৫ / ২০ / ৩০ মিনিট আগে লোকাল রিমাইন্ডার (নেট লাগে না)
- শেষ সার্চ ও রিমাইন্ডার পছন্দ ফোনে JSON ক্যাশে থাকে
- ইন্টারনেট লাগে না
- অনবোর্ডিং একবারই (স্টোরেজ ক্লিয়ার / অ্যাপ রিসেট না করা পর্যন্ত)
- অনবোর্ডিংয়ের পর PDF আপলোড **অপশনাল** — পাশে **আছে এমন ডেটা** দিয়ে bundled CSE রুটিন দিয়ে চালিয়ে যাওয়া যায়; পরে হেডার থেকে PDF বদলানো যায়
- হেডারে জেন্ডার অনুযায়ী ১২ ফেস: মেয়ে (bunny/cat/chick/deer), ছেলে (fox/wolf/raccoon/bear), বলব না → টাক মাথা পুরুষ (হাসি/উইংক/চশমা/টাই)

অ্যাপে ঢুকে **`68_C`** দিয়ে ট্রাই করো — ডেমোর জন্য ভালো উদাহরণ।

---

## চালানো

### যা লাগবে

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12+)
- Android emulator / USB debugging ফোন, অথবা iOS Simulator (Mac)

### এনভ (API বেস URL)

রিপোতে লাইভ API হোস্ট নেই। লোকালে:

```bash
cp .env.example .env
```

`.env`-এ `API_BASE_URL` বসাও (ট্রেইলিং স্ল্যাশ না)। `.env` কমিট করো না।

### কমান্ড

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

শুধু APK:

```bash
flutter build apk --dart-define-from-file=.env
```

অ্যাপে নাম **DIU** — সার্চ বক্সে `68_C`।

লজিক টেস্ট:

```bash
flutter test --dart-define-from-file=.env
```

---

## প্রজেক্ট কীভাবে ভাগ করা

ডেটা একদিকে যায়, স্ক্রিন অন্যদিকে। মাঝখানে **কোয়েরি** — Teacher স্ক্রিন এলেও এই অংশই রিইউজ হবে।

```
DIU Routine PDF
        │
        ▼
scripts/parse_routine_pdf.py          ← PDF পড়ে
        │
        ▼
assets/routine/*.json                 ← অ্যাপে বান্ডল
        │
        ▼
data/RoutinePdfPicker                 ← Kotlin SAF / iOS document picker
        │
        ▼
data/LocalRoutineStore                ← ইউজার PDF → ফোনের routine.json
        │
        ▼
data/AssetRoutineRepository           ← JSON লোড
        │
        ▼
domain/RoutineQueries                 ← সার্চ, সারাংশ, টাইমলাইন, now/next, chips
        │
        ▼
ui/student/StudentViewModel           ← স্ক্রিন স্টেট + student_cache.json
        │
        ├─ ui/app_shell               ← প্রথম লঞ্চ ট্যুর / Student
        ├─ ui/student/StudentScreen   ← Flutter UI + বেল
        └─ data/ClassReminderScheduler ← OS নোটিফিকেশন
```

| ফোল্ডার | দায়িত্ব | এখানে কী লিখবে |
|---|---|---|
| `lib/domain/` | মডেল + নিয়ম (Flutter UI নেই) | সার্চ ম্যাচ, ব্রেক হিসাব, now/next |
| `lib/data/` | JSON পড়া, লোকাল কপি, PDF শেয়ার, রিমাইন্ডার শিডিউল, student cache | নতুন ডেটা সোর্স / মনে রাখা |
| `lib/ui/onboarding/` | প্রথম লঞ্চ ট্যুর | ফিচার + open source / privacy কপি |
| `lib/ui/student/` | Student স্ক্রিন | রং, কার্ড, সার্চ বার, UX পলিশ |
| `lib/ui/theme/` | রং ও টাইপো | কিউট লাইট প্যালেট (ক্রিম + প্যাস্টেল) |
| `assets/routine/` | JSON + সোর্স PDF | নতুন সেমিস্টার ফাইল |
| `scripts/` | PDF → JSON | পার্সার বাগ ফিক্স |
| `data/raw/` | অরিজিনাল PDF | নতুন রুটিন পিডিএফ রাখা |
| `app/` | Kotlin অরিজিনাল | রেফারেন্স; নতুন ফিচার Flutter `lib/`-এ লিখো |

**নিয়ম:** উইজেটে সার্চ লজিক লিখো না। `RoutineQueries` বা `StudentQuery` ব্যবহার করো। নতুন ট্যাব = নতুন `ui/teacher/` — `domain` কপি করে ভাঙবে না।

---

## কোড ম্যাপ (কন্ট্রিবিউটের আগে)

```
lib/
├── main.dart                       অ্যাপ এন্ট্রি, Theme
├── domain/
│   ├── student_query.dart         "68_C" পার্স ও ম্যাচ
│   ├── routine_queries.dart       ফিল্টার, মার্জ, now/next, chips
│   ├── reminder_rules.dart        start − minutesBefore
│   ├── course_label.dart          "OOP - CSE221(68_A)"
│   └── model/                      ClassSlot, ClassReminder, ClassStatus, …
├── data/
│   ├── api/api_config.dart            env থেকে API বেস URL
│   ├── asset_routine_repository.dart   assets থেকে JSON
│   ├── local_routine_store.dart   ইউজার PDF + routine.json
│   ├── routine_pdf_picker.dart    MethodChannel → Kotlin SAF
│   ├── picked_pdf.dart            path + file name
│   ├── routine_pdf_parser.dart    Python পার্সারের Dart পোর্ট
│   ├── pdf_word_extractor.dart    PDF থেকে শব্দ+পজিশন
│   ├── student_cache.dart         সার্চ + রিমাইন্ডার + নাম/জেন্ডার + seenOnboarding
│   ├── student_prefs.dart         লিগ্যাসি SharedPreferences মাইগ্রেশন
│   ├── class_reminder_scheduler.dart  OS লোকাল নোটিফিকেশন
│   ├── course_catalog.dart        কোর্স কোড → নাম
│   ├── schedule_pdf_builder.dart  সেকশন সাপ্তাহিক PDF
│   ├── routine_file_dto.dart      JSON আকৃতি (schemaVersion)
│   └── pdf_exporter.dart          জেনারেটেড PDF শেয়ার
└── ui/
    ├── app_shell.dart             ট্যুর গেট + Student
    ├── onboarding/                পেজ কপি + PageView
    └── student/
        ├── student_view_model.dart    query + day + now/next
        ├── student_screen.dart        লেআউট জোড়া
        └── components/                 Header, Search, Chips, Banner, Date, Timeline, EmptyHint
```

JSON `meta.schemaVersion` এখন `1` — স্লট ফিল্ড আগের মতোই:

```json
{
  "day": "SATURDAY",
  "slot": 1,
  "start": "10:00",
  "end": "11:30",
  "course": "CSE114",
  "group": "71_C",
  "teacher": "SRH",
  "room": "KT-503 (COM LAB)"
}
```

`slot` ০–৫ = `08:30` … `04:00`। ল্যাব প্রায়ই দুইটা পাশাপাশি স্লট — UI সেগুলো এক ব্লকে দেখায়।

---

## নতুন রুটিন PDF থেকে JSON

স্টুডেন্ট অ্যাপে নিজের রুটিন PDF আপলোড করা যায় (অপশনাল) — Android-এ Kotlin SAF পিকার (`MainActivity` + `PdfPicker.kt`)। না দিলে bundled CSE JSON দিয়েই অ্যাপ চলে। ডেভ সময়ে পুরো সেমিস্টার JSON বান্ডল করতে পিসির স্ক্রিপ্টও আছে।

```bash
cd /path/to/this/repo

python3 -m venv scripts/.venv
scripts/.venv/bin/pip install -r scripts/requirements.txt

scripts/.venv/bin/python scripts/parse_routine_pdf.py \
  data/raw/CSE_Class_Routine_V5_Summer-2026.pdf \
  assets/routine/cse_summer_2026_v5.json
```

নতুন সেমিস্টার:

1. PDF রাখো `data/raw/`-এ
2. স্ক্রিপ্ট চালিয়ে নতুন JSON লিখো `assets/routine/`-এ
3. দরকার হলে `AssetRoutineRepository` ও `PdfExporter`-এ ফাইল নাম আপডেট করো
4. অ্যাপে কয়েকটা ব্যাচ সার্চ করে মিলিয়ে দেখো (`68_C`, `71_B`)

পার্সার ১০০% পারফেক্ট নাও হতে পারে — PDF টেবিল ভাঙা। ভুল স্লট দেখলে `scripts/parse_routine_pdf.py` ফিক্স করো, JSON হাতে এডিট শেষ উপায়।

---

## কন্ট্রিবিউট কীভাবে

ছোট PR ভালো। বড় ফিচারের আগে ইস্যু খুলে ডিজাইন এক লাইন লিখে ফেলো।

### ভালো প্রথম কাজ

- Teacher সার্চ (`SRH`) — `RoutineQueries`-এ ফিল্টার, নতুন `ui/teacher/`
- Room সার্চ (`KT-201`)
- খালি রুম (Empty)
- কোনো ব্যাচের ভুল ক্লাস ফিক্স (পার্সার)
- কোর্স কোডের পাশে নাম (আলাদা ম্যাপ ফাইল — PDF-এ নাম নেই)
- খালি স্টেট / এরর মেসেজ আরও পরিষ্কার

### কোড স্টাইল

- এক ফাইল = এক কাজ; নতুন স্ক্রিন সেকশন = নতুন কম্পোনেন্ট ফাইল
- `domain`-এ Flutter / `BuildContext` আনবে না
- সার্চ নিয়ম বদলালে `StudentQuery` / `RoutineQueries`-এ বদলাও, UI-তে নয়
- রং হার্ডকোড না করে `ui/theme/app_colors.dart`
- লাইভ API হোস্ট হার্ডকোড নয় — শুধু `ApiConfig` + লোকাল `.env`

### PR চেকলিস্ট

- [ ] `flutter analyze` চলে
- [ ] `flutter test --dart-define-from-file=.env` চলে
- [ ] PR-এ `.env` বা লাইভ API হোস্ট নেই
- [ ] নিজে ডিভাইসে `68_C` সার্চ করে দেখেছ
- [ ] JSON/পার্সার বদলালে আরও একটা ব্যাচ (`71_B`) চেক
- [ ] README / `PROJECT.md` আপডেট (আর্কিটেকচার বদলালে)

কমিট মেসেজ ছোট রাখো, **কেন** লিখো — যেমন `fix: match 68_C lab subsections`।

---

## এখন ইচ্ছাকৃতভাবে নেই

| ফিচার | কেন পরে |
|---|---|
| Teacher / Room / Empty ট্যাব | v1 শুধু Student |
| কোর্সের পুরো নাম | PDF-এ শুধু কোড |
| অ্যাপে PDF পিকার | আগে JSON পাইপলাইন স্থির |
| লাইভ ওয়েব scrape | নেট ছাড়া ভাঙবে; অফলাইন আগে |

এগুলো যোগ করলেও `RoutineQueries` ও JSON স্কিমা যতটা সম্ভব না ভাঙলেই ভালো।

---

## সমস্যা হলে

| সমস্যা | কী করবে |
|---|---|
| `flutter` কমান্ড নেই | Flutter SDK PATH-এ দাও |
| সার্চ খালি | ফরম্যাট `68_C` — স্পেস বাদ, ইংরেজি অক্ষর |
| ভুল ক্লাস | পার্সার ইস্যু হতে পারে — JSON-এ সেই `group` খুঁজে দেখো |
| PDF শেয়ার খোলে না | emulator-এ শেয়ার টার্গেট নাও থাকতে পারে — ফোনে ট্রাই করো |
| কোর্সের নাম ভুল | `assets/routine/course_names.json` আপডেট করো — PDF সেখান থেকে নাম পড়ে |

---

## ক্রেডিট ও লাইসেন্স

কোড **MIT** — [LICENSE](LICENSE)।

রুটিন PDF **DIU CSE Class Routine Committee**-এর। এই অ্যাপ সেটা শুধু পড়ে দেখায়; অফিসিয়াল রুটিনের মালিকানা বিশ্ববিদ্যালয়ের।

আর্কিটেকচারের ছোট নোট: [PROJECT.md](PROJECT.md)
