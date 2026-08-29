# rDIU Routine Scrapper

DIU ক্লাস রুটিন খোঁজার ওপেন-সোর্স Android অ্যাপ। আপাতত **Student** ভিউ — ব্যাচ/সেকশন দিয়ে দৈনিক রুটিন দেখা যায়।

## কী করে

- ব্যাচ সার্চ: `68_C`, `71_B`, অথবা শুধু `68`
- দিন বেছে ক্লাস টাইমলাইন (ল্যাব পাশাপাশি স্লট একসাথে দেখায়, মাঝে ব্রেক)
- Enrolled Courses সারাংশ + অফিসিয়াল PDF শেয়ার
- অফলাইন — রুটিন JSON অ্যাপের সাথেই আছে

## ডেটা

সোর্স: CSE Class Routine **V5 · Summer 2026** PDF।

পার্সার PDF পড়ে JSON বানায়, অ্যাপ শুধু JSON পড়ে। পরে PDF আপলোড যোগ করলেও এই লেয়ারই থাকবে।

```bash
scripts/.venv/bin/python scripts/parse_routine_pdf.py \
  data/raw/CSE_Class_Routine_V5_Summer-2026.pdf \
  app/src/main/assets/routine/cse_summer_2026_v5.json
```

## চালানো

Android Studio দিয়ে এই ফোল্ডার খুলে Run।

- package: `com.ababilx.routinescrapper`
- minSdk 24 · Compose · Material 3

## ফোল্ডার

| পথ | কাজ |
|---|---|
| `domain/` | মডেল + সার্চ/টাইমলাইন লজিক |
| `data/` | JSON রিডার, PDF শেয়ার |
| `ui/student/` | Student স্ক্রিন ও কম্পোনেন্ট |
| `assets/routine/` | JSON + সোর্স PDF |
| `scripts/` | PDF → JSON |

## এখন নেই (ইচ্ছাকৃত)

Teacher / Room / Empty ট্যাব, কোর্সের পুরো নাম, লাইভ ওয়েব scrape, অ্যাপে runtime PDF parse।

## লাইসেন্স

MIT — [LICENSE](LICENSE)

রুটিন PDF DIU CSE Routine Committee-এর। অ্যাপ শুধু সেটা পড়ে দেখায়।
