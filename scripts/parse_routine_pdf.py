#!/usr/bin/env python3
"""Parse a DIU CSE class-routine PDF into JSON.

Usage:
  scripts/.venv/bin/python scripts/parse_routine_pdf.py \\
      data/raw/CSE_Class_Routine_V5_Summer-2026.pdf \\
      app/src/main/assets/routine/cse_summer_2026_v5.json
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import pymupdf

DAYS = ("SATURDAY", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY")
TIME_SLOTS = [
    ("08:30", "10:00"),
    ("10:00", "11:30"),
    ("11:30", "01:00"),
    ("01:00", "02:30"),
    ("02:30", "04:00"),
    ("04:00", "05:30"),
]
# Room-column x of the 6 slots on the landscape A3 sheet.
SLOT_EDGES = (0, 230, 415, 610, 800, 985, 1300)

COURSE_RE = re.compile(
    r"^([A-Z]{2,5}\d{3}[A-Z]?)\((.+)\)$"
)
TEACHER_RE = re.compile(r"^[A-Z]{2,6}(?:[_-]\d+)?$")
ROOM_RE = re.compile(
    r"^(KT-\d+(?:\([A-Z]\))?|G1-\d+|ANX1-\d+|SH-\d+|CTBA-\d+|EMBED|IOT)$"
)
SKIP = {
    "ROOM",
    "COURSE",
    "TEACHER",
    "COM",
    "LAB",
    "(COM",
    "LAB)",
    "RESERVED",
    "VERSION",
    "V5",
    "CLASS",
    "ROUTINE",
    "FOR",
    "CSE",
    "PROGRAM",
}


def slot_index(x: float) -> int:
    for i, (left, right) in enumerate(zip(SLOT_EDGES, SLOT_EDGES[1:])):
        if left <= x < right:
            return i
    return 5


def is_room(text: str) -> bool:
    return bool(ROOM_RE.match(text.strip()))


def parse_pdf(pdf_path: Path) -> dict:
    doc = pymupdf.open(pdf_path)
    words: list[tuple[int, float, float, str]] = []
    for page_index, page in enumerate(doc):
        for x0, y0, _x1, _y1, text, *_ in page.get_text("words"):
            token = text.strip()
            if token:
                words.append((page_index, y0, x0, token))

    current_day = "SATURDAY"
    slots: list[dict] = []
    seen: set[tuple] = set()
    ordered = sorted(words, key=lambda item: (item[0], item[1], item[2]))

    for page_index, y, x, text in ordered:
        if text in DAYS and x > 500:
            current_day = text
            continue

        match = COURSE_RE.match(text)
        if not match:
            continue

        course, group = match.group(1), match.group(2)
        group = group.rstrip(".")
        index = slot_index(x)
        teacher = find_teacher(words, page_index, y, x, index)
        if teacher in SKIP or teacher == "Reserved":
            continue
        room = find_room_name(words, page_index, y, x, index)
        start, end = TIME_SLOTS[index]
        key = (current_day, start, course, group, teacher, room)
        if key in seen:
            continue
        seen.add(key)
        slots.append(
            {
                "day": current_day,
                "slot": index,
                "start": start,
                "end": end,
                "course": course,
                "group": group,
                "teacher": teacher,
                "room": room,
            }
        )

    slots.sort(key=lambda item: (DAYS.index(item["day"]), item["start"], item["room"]))
    return {
        "meta": {
            "department": "CSE",
            "version": "5.0",
            "semester": "Summer 2026",
            "effectiveFrom": "Saturday 11 July, 2026",
            "sourcePdf": pdf_path.name,
        },
        "slots": slots,
    }


def find_teacher(
    words: list[tuple[int, float, float, str]],
    page: int,
    y: float,
    x: float,
    index: int,
) -> str:
    left, right = SLOT_EDGES[index], SLOT_EDGES[index + 1]
    best: tuple[float, str] | None = None
    for p, wy, wx, text in words:
        if p != page or abs(wy - y) > 4:
            continue
        if wx <= x or wx >= right or wx < left:
            continue
        if COURSE_RE.match(text) or is_room(text) or text.upper() in SKIP:
            continue
        if TEACHER_RE.match(text) or (text.isupper() and 2 <= len(text) <= 6):
            delta = wx - x
            if best is None or delta < best[0]:
                best = (delta, text)
    return best[1] if best else "?"


def find_room_name(
    words: list[tuple[int, float, float, str]],
    page: int,
    y: float,
    x: float,
    index: int,
) -> str:
    left, right = SLOT_EDGES[index], SLOT_EDGES[index + 1]
    best: tuple[float, str] | None = None
    for p, wy, wx, text in words:
        if p != page or wy > y + 2:
            continue
        if not (left <= wx < right):
            continue
        if y - wy > 24:
            continue
        if is_room(text):
            # Prefer the room column (left of the course).
            score = (y - wy) + (0 if wx < x else 40)
            if best is None or score < best[0]:
                suffix = lab_suffix(words, page, wy, index)
                label = f"{text}{suffix}"
                best = (score, label)
    return best[1] if best else "?"


def lab_suffix(
    words: list[tuple[int, float, float, str]],
    page: int,
    room_y: float,
    index: int,
) -> str:
    left, right = SLOT_EDGES[index], SLOT_EDGES[index + 1]
    for p, wy, wx, text in words:
        if p != page:
            continue
        if not (left <= wx < right):
            continue
        if 0 < wy - room_y < 16 and text in {"(COM", "LAB)"}:
            return " (COM LAB)"
    return ""


def main() -> None:
    pdf = Path(sys.argv[1])
    out = Path(sys.argv[2])
    data = parse_pdf(pdf)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"slots={len(data['slots'])} -> {out}")


if __name__ == "__main__":
    main()
