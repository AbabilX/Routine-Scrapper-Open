package com.ababilx.routinescrapper.domain

import com.ababilx.routinescrapper.domain.model.ClassBlock
import com.ababilx.routinescrapper.domain.model.ClassSlot
import com.ababilx.routinescrapper.domain.model.ClassStatus
import com.ababilx.routinescrapper.domain.model.NowNextHint
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.domain.model.TimelineItem
import java.util.Calendar

object RoutineQueries {
    fun forStudent(slots: List<ClassSlot>, query: StudentQuery): List<ClassSlot> =
        slots.filter { query.matches(it.group) }
            .sortedWith(compareBy({ it.day.ordinal }, { it.slot }, { it.start }))

    fun summary(slots: List<ClassSlot>, query: StudentQuery, version: String): StudentSummary {
        val courses = slots.map { it.course }.toSet()
        return StudentSummary(
            batch = query.batch,
            section = query.section.ifEmpty { "All" },
            totalCourses = courses.size,
            classesPerWeek = slots.size,
            routineVersion = version,
        )
    }

    fun timeline(daySlots: List<ClassSlot>): List<TimelineItem> {
        val blocks = merge(daySlots)
        if (blocks.isEmpty()) return emptyList()
        val items = mutableListOf<TimelineItem>()
        blocks.forEachIndexed { index, block ->
            if (index > 0) {
                val prev = blocks[index - 1]
                val gap = minutes(block.start) - minutes(prev.end)
                if (gap >= 30) {
                    items += TimelineItem.Break(prev.end, block.start, gap)
                }
            }
            items += TimelineItem.Class(block)
        }
        return items
    }

    fun blocksForDay(daySlots: List<ClassSlot>): List<ClassBlock> = merge(daySlots)

    fun nowMinutes(calendar: Calendar = Calendar.getInstance()): Int {
        val hour = calendar.get(Calendar.HOUR_OF_DAY)
        val minute = calendar.get(Calendar.MINUTE)
        return hour * 60 + minute
    }

    fun statusOf(
        block: ClassBlock,
        selectedDay: RoutineDay,
        today: RoutineDay = todayOrSaturday(),
        nowMin: Int = nowMinutes(),
        nextStart: String? = null,
    ): ClassStatus {
        if (selectedDay != today) return ClassStatus.LATER
        val start = minutes(block.start)
        val end = minutes(block.end)
        return when {
            nowMin in start until end -> ClassStatus.NOW
            nowMin >= end -> ClassStatus.DONE
            nextStart != null && block.start == nextStart -> ClassStatus.NEXT
            else -> ClassStatus.LATER
        }
    }

    /** Status per class block for the selected day (marks one NEXT after NOW/DONE). */
    fun statusesForDay(
        daySlots: List<ClassSlot>,
        selectedDay: RoutineDay,
        today: RoutineDay = todayOrSaturday(),
        nowMin: Int = nowMinutes(),
    ): Map<ClassBlock, ClassStatus> {
        val blocks = merge(daySlots)
        if (selectedDay != today) {
            return blocks.associateWith { ClassStatus.LATER }
        }
        val nextStart = blocks.firstOrNull { minutes(it.start) > nowMin }?.start
        return blocks.associateWith { statusOf(it, selectedDay, today, nowMin, nextStart) }
    }

    fun nowOrNext(
        daySlots: List<ClassSlot>,
        selectedDay: RoutineDay,
        today: RoutineDay = todayOrSaturday(),
        nowMin: Int = nowMinutes(),
    ): NowNextHint? {
        if (selectedDay != today) return null
        val blocks = merge(daySlots)
        if (blocks.isEmpty()) return null
        blocks.firstOrNull { nowMin in minutes(it.start) until minutes(it.end) }?.let {
            return NowNextHint(ClassStatus.NOW, it)
        }
        blocks.firstOrNull { minutes(it.start) > nowMin }?.let {
            return NowNextHint(ClassStatus.NEXT, it)
        }
        return null
    }

    /** Popular section chips; narrows when the user types a batch like `68`. */
    fun suggestChips(
        slots: List<ClassSlot>,
        queryText: String,
        limit: Int = 8,
    ): List<String> {
        val cleaned = queryText.trim().uppercase().replace(" ", "")
        val counts = linkedMapOf<String, Int>()
        for (slot in slots) {
            val group = slot.group.uppercase()
            if (!group.contains('_')) continue
            counts[group] = (counts[group] ?: 0) + 1
        }
        val ranked = counts.entries
            .sortedWith(compareByDescending<Map.Entry<String, Int>> { it.value }.thenBy { it.key })
            .map { it.key }

        if (cleaned.isEmpty()) return ranked.take(limit)

        val parsed = StudentQuery.parse(cleaned)
        return when {
            parsed != null && parsed.section.isNotEmpty() -> emptyList()
            parsed != null -> ranked.filter { it.startsWith("${parsed.batch}_") }.take(limit)
            cleaned.all { it.isDigit() } -> ranked.filter { it.startsWith("${cleaned}_") }.take(limit)
            else -> emptyList()
        }
    }

    private fun merge(slots: List<ClassSlot>): List<ClassBlock> {
        val ordered = slots.sortedBy { it.slot }
        val result = mutableListOf<ClassBlock>()
        for (slot in ordered) {
            val last = result.lastOrNull()
            if (last != null &&
                last.course == slot.course &&
                last.group == slot.group &&
                last.teacher == slot.teacher &&
                last.room == slot.room &&
                last.endSlot + 1 == slot.slot
            ) {
                result[result.lastIndex] = last.copy(endSlot = slot.slot, end = slot.end)
            } else {
                result += ClassBlock(
                    day = slot.day,
                    startSlot = slot.slot,
                    endSlot = slot.slot,
                    start = slot.start,
                    end = slot.end,
                    course = slot.course,
                    group = slot.group,
                    teacher = slot.teacher,
                    room = slot.room,
                )
            }
        }
        return result
    }

    fun minutes(hhmm: String): Int {
        val parts = hhmm.split(":")
        val hour = parts[0].toInt()
        val minute = parts[1].toInt()
        val normalized = if (hour < 8) hour + 12 else hour
        return normalized * 60 + minute
    }

    fun formatDuration(minutes: Int): String {
        val hours = minutes / 60
        val rest = minutes % 60
        return when {
            hours > 0 && rest > 0 -> "${hours}h ${rest}m"
            hours > 0 -> "${hours}h"
            else -> "${rest}m"
        }
    }

    fun todayOrSaturday(): RoutineDay {
        val javaDay = Calendar.getInstance()
            .get(Calendar.DAY_OF_WEEK)
        return when (javaDay) {
            Calendar.SATURDAY -> RoutineDay.SATURDAY
            Calendar.SUNDAY -> RoutineDay.SUNDAY
            Calendar.MONDAY -> RoutineDay.MONDAY
            Calendar.TUESDAY -> RoutineDay.TUESDAY
            Calendar.WEDNESDAY -> RoutineDay.WEDNESDAY
            Calendar.THURSDAY -> RoutineDay.THURSDAY
            else -> RoutineDay.SATURDAY
        }
    }
}
