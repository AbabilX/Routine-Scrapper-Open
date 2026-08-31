# DIU Routine Scrapper

DIU স্টুডেন্টদের জন্য ক্লাস রুটিন অ্যাপ। ব্যাচ লিখলেই দিনভিত্তিক রুটিন দেখা যায়। নেট না থাকলে শেষবারের ক্যাশ থেকে চলে।

|             |                               |
| ----------- | ----------------------------- |
| প্ল্যাটফর্ম | Flutter (Android + iOS)       |
| প্যাকেজ     | `com.ababilx.routinescrapper` |
| অ্যাপ নাম   | DIU                           |
| ভার্সন      | 0.1.0                         |
| লাইসেন্স    | [GPL-3.0](LICENSE)            |

Kotlin + Compose অরিজিনাল `app/`-এ আছে (রেফারেন্স)। রান করার ডিফল্ট এখন Flutter।

---

## কেন এই প্রজেক্ট শেখার ভালো

ছোট অ্যাপ, কিন্তু আসল অ্যাপের মতো লেয়ার আছে। এখানে পড়লে বোঝা যায়:

1. **UI আলাদা, বিজনেস লজিক আলাদা** — স্ক্রিন বদলালে সার্চ ভাঙে না
2. **ডেটা সোর্স আলাদা** — কোয়েরি একই থাকে
3. **Flutter widgets** — ছোট ছোট কম্পোনেন্ট জোড়া লাগিয়ে একটা স্ক্রিন

পড়ার অর্ডার (প্রথম দিন):

1. এই README
2. `lib/main.dart` → `lib/ui/student/student_screen.dart`
3. `student_view_model.dart` → `lib/domain/routine_queries.dart`

---

## কী কী করা যায়

- সার্চ: ব্যাচ টাইপ করলে সাজেশন, সিলেক্ট করলে রুটিন (`70_E`)
- Teacher / Room / Empty ট্যাব
- শনি–বৃহস্পতি ডেট স্ট্রিপ
- পাশাপাশি ল্যাব স্লট এক কার্ডে, মাঝের ফাঁক **Break**
- Enrolled Courses সারাংশ + ডাউনলোড: সার্চ করা সেকশনের সাপ্তাহিক PDF
- ক্লাস কার্ডে বেল — ৫ / ১০ / ১৫ / ২০ / ৩০ মিনিট আগে লোকাল রিমাইন্ডার
- শেষ সার্চ ও রিমাইন্ডার ফোনে ক্যাশে থাকে
- অনবোর্ডিং একবারই (স্টোরেজ ক্লিয়ার / অ্যাপ রিসেট না করা পর্যন্ত)
- হেডারে জেন্ডার অনুযায়ী ১২ ফেস: মেয়ে (bunny/cat/chick/deer), ছেলে (fox/wolf/raccoon/bear), বলব না → টাক মাথা পুরুষ (হাসি/উইংক/চশমা/টাই)

অ্যাপে ঢুকে **`70_E`** দিয়ে ট্রাই করো।

---

## চালানো

### যা লাগবে

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12+)
- Android emulator / USB debugging ফোন, অথবা iOS Simulator (Mac)

### `.env` সেটআপ (বাধ্যতামূলক)

API হোস্ট কম্পাইল-টাইমে `API_BASE_URL` দিয়ে যায়। শুধু `flutter run` চালালে সার্চে **API_BASE_URL is not configured** দেখাবে।

1. `.env.example` কপি করে `.env` বানাও (`.env` কমিট করো না)
2. `.env`-এ `API_BASE_URL=` ভ্যালু দাও — ট্রেইলিং স্ল্যাশ ছাড়া
3. সবসময় `--dart-define-from-file=.env` দিয়ে রান / বিল্ড / টেস্ট করো

```bash
cp .env.example .env
# সম্পাদনা করো: API_BASE_URL=<your-base-url>
flutter pub get
flutter run --dart-define-from-file=.env
```

শুধু APK:

```bash
flutter build apk --dart-define-from-file=.env
```

লজিক টেস্ট:

```bash
flutter test --dart-define-from-file=.env
```

Cursor / VS Code থেকে রান করলে `.vscode/launch.json`-এ ইতিমধ্যে `--dart-define-from-file=.env` আছে — সেখান থেকে Run/Debug করলেই হবে।

অ্যাপে নাম **DIU** — সার্চ বক্সে `70_E`।

---

## প্রজেক্ট কীভাবে ভাগ করা

ডেটা একদিকে যায়, স্ক্রিন অন্যদিকে। মাঝখানে **কোয়েরি** — Teacher স্ক্রিন এলেও এই অংশই রিইউজ হবে।

```
data/                         ← রুটিন লোড + ক্যাশ
        │
        ▼
domain/RoutineQueries         ← সার্চ, সারাংশ, টাইমলাইন, now/next
        │
        ▼
ui/*/ViewModel                ← স্টুডেন্ট / টিচার / রুম স্টেট
        │
        ├─ ui/app_shell
        ├─ ui/student / teacher / room
        └─ data/ClassReminderScheduler
```

| ফোল্ডার              | দায়িত্ব                                 | এখানে কী লিখবে                              |
| -------------------- | ---------------------------------------- | ------------------------------------------- |
| `lib/domain/`        | মডেল + নিয়ম (Flutter UI নেই)            | সার্চ ম্যাচ, ব্রেক হিসাব, now/next          |
| `lib/data/`          | রুটিন লোড, ক্যাশ, PDF শেয়ার, রিমাইন্ডার | নতুন ডেটা সোর্স / মনে রাখা                  |
| `lib/ui/onboarding/` | প্রথম লঞ্চ ট্যুর                         | ফিচার + open source / privacy কপি           |
| `lib/ui/student/`    | Student স্ক্রিন                          | রং, কার্ড, সার্চ বার, UX পলিশ               |
| `lib/ui/teacher/`    | Teacher স্ক্রিন                          | টিচার ইনিশিয়াল সার্চ                       |
| `lib/ui/room/`       | Room / Empty স্ক্রিন                     | রুম ও খালি ক্লাসরুম                         |
| `lib/ui/theme/`      | রং ও টাইপো                               | কিউট লাইট প্যালেট (ক্রিম + প্যাস্টেল)       |
| `app/`               | Kotlin অরিজিনাল                          | রেফারেন্স; নতুন ফিচার Flutter `lib/`-এ লিখো |

**নিয়ম:** উইজেটে সার্চ লজিক লিখো না। `RoutineQueries` বা `StudentQuery` ব্যবহার করো। নতুন ট্যাব = নতুন `ui/teacher/` — `domain` কপি করে ভাঙবে না।

---

## কোড ম্যাপ (কন্ট্রিবিউটের আগে)

```
lib/
├── main.dart                       অ্যাপ এন্ট্রি, Theme
├── domain/
│   ├── student_query.dart         "70_E" পার্স ও ম্যাচ
│   ├── routine_queries.dart       ফিল্টার, মার্জ, now/next, chips
│   ├── reminder_rules.dart        start − minutesBefore
│   ├── course_label.dart          "OOP - CSE221(68_A)"
│   └── model/                      ClassSlot, ClassReminder, ClassStatus, …
├── data/
│   ├── student_cache.dart         সার্চ + রিমাইন্ডার + নাম/জেন্ডার + seenOnboarding
│   ├── class_reminder_scheduler.dart  OS লোকাল নোটিফিকেশন
│   ├── course_catalog.dart        কোর্স কোড → নাম
│   ├── schedule_pdf_builder.dart  সেকশন সাপ্তাহিক PDF
│   └── pdf_exporter.dart          জেনারেটেড PDF শেয়ার
└── ui/
    ├── app_shell.dart             ট্যুর গেট + ট্যাব
    ├── onboarding/                পেজ কপি + PageView
    ├── student/                   স্টুডেন্ট রুটিন
    ├── teacher/                   টিচার রুটিন
    └── room/                      রুম / খালি রুম
```

`slot` ০–৫ = `08:30` … `04:00`। ল্যাব প্রায়ই দুইটা পাশাপাশি স্লট — UI সেগুলো এক ব্লকে দেখায়।

---

## কন্ট্রিবিউট কীভাবে

ছোট PR ভালো। বড় ফিচারের আগে ইস্যু খুলে ডিজাইন এক লাইন লিখে ফেলো।

### কোড স্টাইল

- এক ফাইল = এক কাজ; নতুন স্ক্রিন সেকশন = নতুন কম্পোনেন্ট ফাইল
- `domain`-এ Flutter / `BuildContext` আনবে না
- সার্চ নিয়ম বদলালে `StudentQuery` / `RoutineQueries`-এ বদলাও, UI-তে নয়
- রং হার্ডকোড না করে `ui/theme/app_colors.dart`

### PR চেকলিস্ট

- [ ] `flutter analyze` চলে
- [ ] `flutter test --dart-define-from-file=.env` চলে
- [ ] PR-এ `.env` নেই
- [ ] নিজে ডিভাইসে `70_E` সার্চ করে দেখেছ
- [ ] README / `PROJECT.md` আপডেট (আর্কিটেকচার বদলালে)

কমিট মেসেজ ছোট রাখো, **কেন** লিখো — যেমন `fix: match 70_E lab subsections`।

---

## এখন ইচ্ছাকৃতভাবে নেই

| ফিচার          | কেন পরে            |
| -------------- | ------------------ |
| BBA department | এই ভার্সন CSE only |

`RoutineQueries` ও `ClassSlot` স্কিমা যতটা সম্ভব না ভাঙলেই ভালো।

---

## সমস্যা হলে

| সমস্যা                            | কী করবে                                                                 |
| --------------------------------- | ----------------------------------------------------------------------- |
| `flutter` কমান্ড নেই              | Flutter SDK PATH-এ দাও                                                  |
| `API_BASE_URL is not configured`  | `.env` বানাও + `flutter run --dart-define-from-file=.env`               |
| সার্চ খালি                        | ফরম্যাট `70_E` — স্পেস বাদ, ইংরেজি অক্ষর                                |
| PDF শেয়ার খোলে না                | emulator-এ শেয়ার টার্গেট নাও থাকতে পারে — ফোনে ট্রাই করো               |
| কোর্সের নাম ভুল                   | `assets/routine/course_names.json` আপডেট করো                            |

---

## ক্রেডিট ও লাইসেন্স

কোড **GNU GPL-3.0** (বা পরের ভার্সন) — [LICENSE](LICENSE)।

মানে: ব্যবহার, পড়া, কন্ট্রিবিউট, এবং ফোর্ক করা যায়। কেউ মডিফাই করে ডিস্ট্রিবিউট করলে **একই GPL** ও সোর্স কোড দিতে হবে — ক্লোজড/প্রোপ্রাইটারি করে রিব্র্যান্ড করা যায় না।

রুটিন **DIU CSE Class Routine Committee**-এর। এই অ্যাপ সেটা শুধু দেখায়; অফিসিয়াল রুটিনের মালিকানা বিশ্ববিদ্যালয়ের।

আর্কিটেকচারের ছোট নোট: [PROJECT.md](PROJECT.md)
