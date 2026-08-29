package com.ababilx.routinescrapper.domain.model

data class ClassSlot(
    val day: RoutineDay,
    val slot: Int,
    val start: String,
    val end: String,
    val course: String,
    val group: String,
    val teacher: String,
    val room: String,
)
