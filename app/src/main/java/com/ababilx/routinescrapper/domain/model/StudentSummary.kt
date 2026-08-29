package com.ababilx.routinescrapper.domain.model

data class StudentSummary(
    val batch: String,
    val section: String,
    val totalCourses: Int,
    val classesPerWeek: Int,
    val routineVersion: String,
)

data class ClassBlock(
    val day: RoutineDay,
    val startSlot: Int,
    val endSlot: Int,
    val start: String,
    val end: String,
    val course: String,
    val group: String,
    val teacher: String,
    val room: String,
)

sealed class TimelineItem {
    data class Class(val block: ClassBlock) : TimelineItem()
    data class Break(val start: String, val end: String, val minutes: Int) : TimelineItem()
}
