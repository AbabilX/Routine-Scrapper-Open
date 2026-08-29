package com.ababilx.routinescrapper.domain

import com.ababilx.routinescrapper.domain.model.ClassBlock
import com.ababilx.routinescrapper.domain.model.ClassSlot
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.domain.model.TimelineItem

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
        val javaDay = java.util.Calendar.getInstance()
            .get(java.util.Calendar.DAY_OF_WEEK)
        return when (javaDay) {
            java.util.Calendar.SATURDAY -> RoutineDay.SATURDAY
            java.util.Calendar.SUNDAY -> RoutineDay.SUNDAY
            java.util.Calendar.MONDAY -> RoutineDay.MONDAY
            java.util.Calendar.TUESDAY -> RoutineDay.TUESDAY
            java.util.Calendar.WEDNESDAY -> RoutineDay.WEDNESDAY
            java.util.Calendar.THURSDAY -> RoutineDay.THURSDAY
            else -> RoutineDay.SATURDAY
        }
    }
}
