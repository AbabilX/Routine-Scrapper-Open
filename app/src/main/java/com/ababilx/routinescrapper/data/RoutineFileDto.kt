package com.ababilx.routinescrapper.data

import kotlinx.serialization.Serializable

@Serializable
data class RoutineFileDto(
    val meta: RoutineMetaDto,
    val slots: List<ClassSlotDto>,
)

@Serializable
data class RoutineMetaDto(
    val department: String,
    val version: String,
    val semester: String,
    val effectiveFrom: String,
    val sourcePdf: String,
)

@Serializable
data class ClassSlotDto(
    val day: String,
    val slot: Int,
    val start: String,
    val end: String,
    val course: String,
    val group: String,
    val teacher: String,
    val room: String,
)
