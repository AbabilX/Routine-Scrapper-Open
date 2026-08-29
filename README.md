# rDIU Routine Scrapper

DIU স্টুডেন্টদের জন্য **অফলাইন ক্লাস রুটিন** অ্যাপ। PDF ঘেঁটে ব্যাচ খুঁজে বের করার বদলে ব্যাচ কোড লিখলেই দিনভিত্তিক রুটিন দেখা যায়।

এখন শুধু **Student** ভিউ আছে। Teacher / Room / Empty পরে যোগ হবে — আর্কিটেকচার সেভাবেই রাখা।

| | |
|---|---|
| প্ল্যাটফর্ম | Android (Kotlin + Jetpack Compose) |
| প্যাকেজ | `com.ababilx.routinescrapper` |
| minSdk / targetSdk | 24 / 36 |
| ডেটা | CSE Routine **V5 · Summer 2026** (অ্যাপে বান্ডল) |
| লাইসেন্স | [MIT](LICENSE) |

---

## কেন এই প্রজেক্ট শেখার ভালো

ছোট অ্যাপ, কিন্তু আসল অ্যাপের মতো লেয়ার আছে। এখানে পড়লে বোঝা যায়:

1. **UI আলাদা, বিজনেস লজিক আলাদা** — স্ক্রিন বদলালে সার্চ ভাঙে না
2. **ডেটা সোর্স আলাদা** — আজ JSON, কাল PDF আপলোড; কোয়েরি একই থাকে
3. **Compose** — ছোট ছোট কম্পোনেন্ট জোড়া লাগিয়ে একটা স্ক্রিন
4. **PDF scraper** — ইউনিভার্সিটি রুটিন PDF কীভাবে স্ট্রাকচার্ড JSON হয়

পড়ার অর্ডার (প্রথম দিন):

1. এই README
2. `MainActivity.kt` → `StudentScreen.kt`
3. `StudentViewModel.kt` → `RoutineQueries.kt`
4. `AssetRoutineRepository.kt`

---

## কী কী করা যায়

- সার্চ: `68_C`, `71_B`, `68C`, বা শুধু `68` (সব সেকশন)
- `68_C` লিখলে `68_C1` / `68_C2` ল্যাব সাবসেকশনও মিলে
- শনি–বৃহস্পতি ডেট স্ট্রিপ
- পাশাপাশি ল্যাব স্লট এক কার্ডে, মাঝের ফাঁক **Break**
- Enrolled Courses সারাংশ + অফিসিয়াল PDF শেয়ার
- ইন্টারনেট লাগে না

অ্যাপে ঢুকে **`68_C`** দিয়ে ট্রাই করো — ডেমোর জন্য ভালো উদাহরণ।

---

## চালানো

### যা লাগবে

- [Android Studio](https://developer.android.com/studio) (Meerkat / নতুন ভার্সন)
- **JDK 17 বা 21** — Studio-এর সাথে JBR আসে। Homebrew **Java 26** দিয়ে সরাসরি AGP চলে না (এরর শুধু `26.0.1` দেখায়)। প্রজেক্ট Gradle ডেমনকে JDK 21-এ লক করে; Mac-এ Android Studio থাকলে আর কিছু করতে হয় না।
- Android SDK (Studio প্রথমবার নিজে নামিয়ে নেয়)
- একটি emulator, অথবা USB debugging চালু ফোন

### Android Studio (রিকমেন্ডেড)

1. **Open** → এই রিপোর রুট ফোল্ডার (`kotlin` / যে নামে ক্লোন করেছ)
2. নিচে **Gradle Sync** শেষ হওয়া পর্যন্ত অপেক্ষা
3. উপরের ডিভাইস লিস্ট থেকে emulator বা ফোন বাছো  
   - Emulator না থাকলে: **Device Manager** → **Create Device** → Pixel → সিস্টেম ইমেজ ডাউনলোড
4. সবুজ **Run ▶** (`⌃R` / `Ctrl+R`)
5. অ্যাপ নাম **rDIU** — সার্চ বক্সে `68_C`

প্রথমবার Gradle ডিপেন্ডেন্সি ডাউনলোডে কয়েক মিনিট লাগতে পারে।

### টার্মিনাল

ফোন বা emulator **আগে চালু** রাখো (`adb devices`-এ ডিভাইস দেখা যাবে), তারপর প্রজেক্ট রুট থেকে:

```bash
./gradlew :app:installDebug
```

শুধু APK বানাতে (ডিভাইস লাগে না):

```bash
./gradlew :app:assembleDebug
```

আউটপুট: `app/build/outputs/apk/debug/app-debug.apk`

Android Studio `/Applications`-এ না থাকলে (বা আবার `26.0.1` এরর এলে):

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
./gradlew :app:installDebug
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
data/AssetRoutineRepository           ← JSON লোড
        │
        ▼
domain/RoutineQueries                 ← সার্চ, সারাংশ, টাইমলাইন, now/next, chips
        │
        ▼
ui/student/StudentViewModel           ← স্ক্রিন স্টেট + শেষ সার্চ মনে রাখা
        │
        ▼
ui/student/StudentScreen              ← Compose UI
```

| ফোল্ডার | দায়িত্ব | এখানে কী লিখবে |
|---|---|---|
| `domain/` | মডেল + নিয়ম (Android UI নেই) | সার্চ ম্যাচ, ব্রেক হিসাব, now/next |
| `data/` | JSON পড়া, PDF শেয়ার, prefs | নতুন ডেটা সোর্স / মনে রাখা |
| `ui/student/` | Student স্ক্রিন | রং, কার্ড, সার্চ বার, UX পলিশ |
| `ui/theme/` | রং ও টাইপো | কিউট লাইট প্যালেট (ক্রিম + প্যাস্টেল) |
| `app/src/main/assets/routine/` | JSON + সোর্স PDF | নতুন সেমিস্টার ফাইল |
| `scripts/` | PDF → JSON | পার্সার বাগ ফিক্স |
| `data/raw/` | অরিজিনাল PDF | নতুন রুটিন পিডিএফ রাখা |

**নিয়ম:** কম্পোজেবলে সার্চ লজিক লিখো না। `RoutineQueries` বা `StudentQuery` ব্যবহার করো। নতুন ট্যাব = নতুন `ui/teacher/` — `domain` কপি করে ভাঙবে না।

---

## কোড ম্যাপ (কন্ট্রিবিউটের আগে)

```
app/src/main/java/com/ababilx/routinescrapper/
├── MainActivity.kt                 অ্যাপ এন্ট্রি, Theme
├── domain/
│   ├── StudentQuery.kt             "68_C" পার্স ও ম্যাচ
│   ├── RoutineQueries.kt           ফিল্টার, মার্জ, now/next, chips
│   └── model/                      ClassSlot, ClassStatus, …
├── data/
│   ├── AssetRoutineRepository.kt   assets থেকে JSON
│   ├── StudentPrefs.kt             শেষ ব্যাচ সার্চ (DataStore)
│   ├── RoutineFileDto.kt           JSON আকৃতি
│   └── PdfExporter.kt              PDF শেয়ার
└── ui/student/
    ├── StudentViewModel.kt         query + day + now/next
    ├── StudentScreen.kt            লেআউট জোড়া
    └── components/                 Header, Search, Chips, Banner, Date, Timeline, EmptyHint
```

JSON-এর একটা স্লট এরকম:

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

অ্যাপ PDF সরাসরি পড়ে না (মোবাইলে গ্রিড পার্স অস্থির)। পিসিতে একবার পার্স করে JSON বান্ডল করা হয়।

```bash
cd /path/to/this/repo

python3 -m venv scripts/.venv
scripts/.venv/bin/pip install -r scripts/requirements.txt

scripts/.venv/bin/python scripts/parse_routine_pdf.py \
  data/raw/CSE_Class_Routine_V5_Summer-2026.pdf \
  app/src/main/assets/routine/cse_summer_2026_v5.json
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
- `domain`-এ Compose / `Context` আনবে না
- সার্চ নিয়ম বদলালে `StudentQuery` / `RoutineQueries`-এ বদলাও, UI-তে নয়
- রং হার্ডকোড না করে `ui/theme/Color.kt`

### PR চেকলিস্ট

- [ ] `./gradlew :app:compileDebugKotlin` চলে
- [ ] নিজে emulator-এ `68_C` সার্চ করে দেখেছ
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
| বিল্ড ফেল, মেসেজ শুধু `26.0.1` | Homebrew Java 26। নতুন `gradle.properties` পুল করে আবার `./gradlew :app:installDebug`। না চললে নিচে `JAVA_HOME` সেট করো |
| `Cannot find a Java installation … Java 21` | Android Studio ইনস্টল করো, অথবা `JAVA_HOME` Studio JBR-এ সেট করো |
| Gradle Sync ফেল | ইন্টারনেট চেক, File → Invalidate Caches, আবার Sync |
| অ্যাপ ইনস্টল হয় না | emulator/ফোন চালু আছে কিনা — `adb devices` খালি হলে `installDebug` ফেল করবে |
| সার্চ খালি | ফরম্যাট `68_C` — স্পেস বাদ, ইংরেজি অক্ষর |
| ভুল ক্লাস | পার্সার ইস্যু হতে পারে — JSON-এ সেই `group` খুঁজে দেখো |

---

## ক্রেডিট ও লাইসেন্স

কোড **MIT** — [LICENSE](LICENSE)।

রুটিন PDF **DIU CSE Class Routine Committee**-এর। এই অ্যাপ সেটা শুধু পড়ে দেখায়; অফিসিয়াল রুটিনের মালিকানা বিশ্ববিদ্যালয়ের।

আর্কিটেকচারের ছোট নোট: [PROJECT.md](PROJECT.md)
